//
//  TagManager.swift
//  bacon
//
//  Tag and TagManager are defined in the same file
//  because we want one of Tag's init() methods to
//  remain fileprivate.
//  This is to guard against accidentally initializing
//  a Tag object. Since Tag objects compute their
//  values through TagManager, initializing a Tag
//  directly will result in an error when its
//  computed property is accessed.
//
//  Created by Fabian Terh on 10/4/19.
//  Copyright © 2019 nus.CS3217. All rights reserved.
//

import Foundation

// swiftlint:disable file_length
// MARK: Tag
struct Tag: Codable, Comparable, Hashable {

    // Internal values uniquely identify a Tag
    let internalValue: String
    let parentInternalValue: String?

    // Override computed properties: this improves testability by dissociating Tag from TagManager.
    // Normally (in production), a Tag's value and parentValue properties are computed
    // with reference to the singleton TagManager.
    // These overriding properties allow for the creation of standalone Tags
    // that work independently of TagManager.
    private var overriddenValue: String?
    private var overriddenParentValue: String?
    private var isParentValueOverridden: Bool = false // We require an extra flag
    // for parentValue because parentValue can normally be nil anyway

    /// Returns the user-defined display value of a Tag, or an empty string if unavailable.
    /// The only period of unavailablility is when TagManager has not been fully instantiated.
    /// It should never be unavailable in normal usage.
    private(set) var value: String {
        get {
            if let overriddenValue = overriddenValue {
                return overriddenValue
            }

            if TagManager.inTestMode {
                return TagManager.cachedPersistentTagManagerTest?.getDisplayValue(of: internalValue) ?? ""
            } else {
                return TagManager.cachedPersistentTagManager?.getDisplayValue(of: internalValue) ?? ""
            }
        }

        set(newValue) {
            overriddenValue = newValue
        }
    }

    /// Returns the user-defined display value of a Tag's parent.
    /// Returns `nil` if a Tag does not have a parent, or an empty string if unavailable.
    /// The only period of unavailablility is when TagManager has not been fully instantiated.
    /// It should never be unavailable in normal usage.
    private(set) var parentValue: String? {
        get {
            if isParentValueOverridden {
                return overriddenParentValue
            }

            // Guard against having no parent Tag
            guard let parentInternalValue = parentInternalValue else {
                return nil
            }

            if TagManager.inTestMode {
                return TagManager.cachedPersistentTagManagerTest?.getDisplayValue(of: parentInternalValue) ?? ""
            } else {
                return TagManager.cachedPersistentTagManager?.getDisplayValue(of: parentInternalValue) ?? ""
            }
        }

        set(newValue) {
            overriddenParentValue = newValue
            isParentValueOverridden = true
        }
    }

    private enum CodingKeys: String, CodingKey {
        case internalValue
        case parentInternalValue
        case overriddenValue
        case overriddenParentValue
        case isParentValueOverridden
    }

    /// Initializes a Tag.
    fileprivate init(_ internalValue: String, parentInternalValue: String?) {
        self.internalValue = internalValue
        self.parentInternalValue = parentInternalValue
    }

    /// Initializes a standalone Tag.
    /// Standalone Tags work independently and are not associated to TagManager.
    /// Its `value` and optional `parentValue` properties are specified during instantiation.
    init(_ value: String, parentValue: String? = nil) {
        overriddenValue = value
        overriddenParentValue = parentValue

        self.internalValue = value
        self.parentInternalValue = parentValue != nil ? parentValue : nil
    }

    /// Convenience computed property to represent whether a Tag is a child Tag.
    var isChild: Bool {
        return parentValue != nil
    }

    /// Convenience computed property to represent whether a Tag is a parent Tag.
    var isParent: Bool {
        return !isChild
    }

    // Exclude `manager` property from Equatable logic
    static func == (lhs: Tag, rhs: Tag) -> Bool {
        return lhs.internalValue == rhs.internalValue && lhs.parentInternalValue == rhs.parentInternalValue
    }

    // Generally, we should only compare by the `value` property, since it's
    // not meaningful to compare children Tags (of different parents), or a child Tag with a parent Tag.
    static func < (lhs: Tag, rhs: Tag) -> Bool {
        // 4 possible scenarios:
        // 1) child vs child,
        // 2) parent vs parent,
        // 3) child vs parent,
        // 4) parent vs child

        if lhs.isChild && rhs.isChild {
            // Compare their `value` properties first, then compare their `parent` properties
            if lhs.value != rhs.value {
                return lhs.value < rhs.value
            }

            // 2 sub-scenarios: (1) same parent, (2) different parents
            guard let lhsParent = lhs.parentValue else {
                fatalError("This should never happen")
            }
            guard let rhsParent = rhs.parentValue else {
                fatalError("This should never happen")
            }
            assert(lhsParent != rhsParent)
            return lhsParent < rhsParent
        } else if lhs.isParent && rhs.isParent {
            return lhs.value < rhs.value
        } else if lhs.isChild && rhs.isParent {
            // Compare their `value` properties first.
            // If equal, a parent Tag should come before a child Tag.
            if lhs.value != rhs.value {
                return lhs.value < rhs.value
            }
            return false
        } else { // lhs.isParent && rhs.isChild
            if lhs.value != rhs.value {
                return lhs.value < rhs.value
            }
            return true
        }
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(internalValue)
        hasher.combine(parentInternalValue)
    }

    func toString() -> String {
        var tagName = self.value
        if let parentName = self.parentValue {
            tagName = parentName + "/" + tagName
        }
        return tagName
    }

}

// MARK: TagManager: TagManagerInterface
class TagManager: Codable, Observable, TagManagerInterface {

    // Support persistence
    private static let saveFileName = "TagManager"
    private static let saveFileNameTest = "TagManagerTest"
    private static let errorLoadData = "Loading of TagManager data failed"
    fileprivate static var cachedPersistentTagManager: TagManager?
    fileprivate static var cachedPersistentTagManagerTest: TagManager?
    fileprivate static var inTestMode: Bool = false // Static flag
    private var inTestMode: Bool // Instance flag

    // Data stores
    // Map parent to child Tags by display values
    private var parentChildMap: [String: Set<String>] = [:]
    // Map all IDs to display values
    private var allIdValueMap: [String: String] = [:]
    // Map only parent display values to IDs
    private var parentValueIdMap: [String: String] = [:]
    // Map parent IDs to children Tag display value to IDs mapping
    private var parentChildValueIdMap: [String: [String: String]] = [:]

    // Observable
    var observers: [Observer] = []

    // See: https://developer.apple.com/documentation/foundation/archives_and_serialization/encoding_and_decoding_custom_types
    // We exclude the "observers" property from being encoded/decoded,
    // since that information should not be persistent across sessions.
    private enum CodingKeys: String, CodingKey {
        case inTestMode
        case parentChildMap
        case allIdValueMap
        case parentValueIdMap
        case parentChildValueIdMap
    }

    /// Creates and returns a TagManager object.
    /// - Note: A persistent TagManager is implemented as a singleton, and thus will never be outdated.
    /// - Parameter withPersistence: If `true`, changes to TagManager data (e.g. add/remove Tags) will
    ///     automatically be saved to storage. The TagManager object returned will also be pre-loaded
    ///     with pre-existing data. If `false`, the TagManager object returned will only manage Tags in memory.
    static func create(testMode: Bool) -> TagManager {
        log.info("Creating TagManager with testMode=\(testMode).")
        TagManager.inTestMode = testMode

        // If a persistent TagManager has previously been instantiated,
        // we return it. Otherwise, we create a new instance and cache it.
        // We do this regardless of `testMode`.

        if testMode {
            if let tagManager = TagManager.cachedPersistentTagManagerTest {
                log.info("Returning cached instance of test TagManager.")
                return tagManager
            }

            log.info("No cached instance of test TagManager found. Instantiating TagManager.")
            let fsm = FileStorageManager()
            let tagManager: TagManager

            do {
                log.info("Reading test TagManager data.")
                tagManager = try fsm.readFromJson(TagManager.self, file: TagManager.saveFileNameTest)
                log.info("Loaded TagManager from data.")
            } catch {
                log.warning("\(TagManager.errorLoadData). Creating a new instance.")
                tagManager = TagManager(testMode: testMode)
            }

            log.info("Caching test TagManager for future returns.")
            TagManager.cachedPersistentTagManagerTest = tagManager
            return tagManager
        }

        if let tagManager = TagManager.cachedPersistentTagManager {
            log.info("Returning cached instance of TagManager.")
            return tagManager
        }

        log.info("No cached instance of TagManager found. Instantiating TagManager.")
        let fsm = FileStorageManager()
        let tagManager: TagManager

        do {
            log.info("Reading TagManager data.")
            tagManager = try fsm.readFromJson(TagManager.self, file: TagManager.saveFileName)
            log.info("Loaded TagManager from data.")
        } catch {
            log.warning("\(TagManager.errorLoadData). Creating a new instance.")
            tagManager = TagManager(testMode: testMode)
        }

        log.info("Caching TagManager for future returns.")
        TagManager.cachedPersistentTagManager = tagManager
        return tagManager
    }

    // Private init to disallow direct instantiation: we want to adopt a semi-singleton design pattern.
    // When TagManager is instantiated in non-persistent mode (e.g. for unit testing),
    // we can create as many instances as possible.
    // However, in normal operation (persistent mode), we want to allow only 1 instance,
    // to avoid multiple working stores of tag data.
    private init(testMode: Bool) {
        inTestMode = testMode
    }

    func getTag(for value: String, of parentValue: String? = nil) throws -> Tag {
        let isParent = parentValue == nil
        if isParent {
            guard parentChildMap[value] != nil else {
                throw InvalidTagError(message: "Parent tag \(value) does not exist")
            }
            guard let uid = parentValueIdMap[value] else {
                fatalError("This should never happen")
            }
            return Tag(uid, parentInternalValue: nil)
        } else { // Is child Tag
            guard let parentValue = parentValue else {
                fatalError("This should never happen")
            }
            guard let childrenTagValues = parentChildMap[parentValue] else {
                throw InvalidTagError(message: "Parent tag \(parentValue) does not exist")
            }
            guard childrenTagValues.contains(value) else {
                throw InvalidTagError(message: "Child tag \(value) does not exist")
            }

            guard let parentId = parentValueIdMap[parentValue] else {
                fatalError("This should never happen")
            }
            guard let uid = parentChildValueIdMap[parentId]?[value] else {
                fatalError("This should never happen")
            }
            return Tag(uid, parentInternalValue: parentId)
        }
    }

    func addChildTag(_ child: String, to parent: String) throws -> Tag {
        // Parent Tag should exist
        guard let children = parentChildMap[parent] else {
            throw InvalidTagError(message: "Parent tag \(parent) does not exist")
        }

        // Child Tag should not exist
        guard !children.contains(child) else {
            throw DuplicateTagError(message: "Child tag \(child) already exists")
        }

        return createTag(child, of: parent)

    }

    func addParentTag(_ parent: String) throws -> Tag {
        // Parent Tag should not exist
        guard parentChildMap[parent] == nil else {
            throw DuplicateTagError(message: "Parent tag \(parent) already exists")
        }

        return createTag(parent)

    }

    @discardableResult
    func removeChildTag(_ child: String, from parent: String) throws -> [Tag] {
        // Parent Tag should exist
        guard let children = parentChildMap[parent] else {
            throw InvalidTagError(message: "Parent tag \(parent) does not exist")
        }

        // Child Tag should exist
        guard children.contains(child) else {
            throw InvalidTagError(message: "Child tag \(child) does not exist")
        }

        return try removeTag(child, of: parent)
    }

    @discardableResult
    func removeParentTag(_ parent: String) throws -> [Tag] {
        // Parent Tag should exist
        guard parentChildMap[parent] != nil else {
            throw InvalidTagError(message: "Parent tag \(parent) does not exist")
        }

        return try removeTag(parent)
    }

    var tags: [Tag: [Tag]] {
        var ret: [Tag: [Tag]] = [:]

        // Add parent Tags
        for parentDisplayValue in parentValueIdMap.keys {
            guard let parentId = parentValueIdMap[parentDisplayValue] else {
                fatalError("This should never happen")
            }
            ret[Tag(parentId, parentInternalValue: nil)] = []
        }

        // Add children Tags
        for parentTag in ret.keys {
            guard let childrenIds = parentChildValueIdMap[parentTag.internalValue]?.values else {
                fatalError("This should never happen")
            }

            for childId in childrenIds {
                ret[parentTag]?.append(Tag(childId, parentInternalValue: parentTag.internalValue))
            }

            // Sort
            ret[parentTag]?.sort()
        }

        return ret
    }

    var parentTags: [Tag] {
        var arrParentTags = Array(parentValueIdMap.values).map { Tag($0, parentInternalValue: nil) }
        arrParentTags.sort()
        return arrParentTags
    }

    func getChildrenTags(of parent: String) throws -> [Tag] {
        // Parent Tag should exist
        guard let parentId = parentValueIdMap[parent] else {
            throw InvalidTagError(message: "Parent tag\(parent) does not exist")
        }

        guard let childrenIds = parentChildValueIdMap[parentId]?.values else {
            fatalError("This should never happen")
        }

        var arrChildrenTags = Array(childrenIds).map { Tag($0, parentInternalValue: parentId) }
        arrChildrenTags.sort()
        return arrChildrenTags
    }

    func isChildTag(_ child: String, of parent: String) -> Bool {
        // Parent Tag should exist, otherwise return false
        guard let childrenDisplayValues = parentChildMap[parent] else {
            return false
        }

        return childrenDisplayValues.contains(child)
    }

    func isParentTag(_ parent: String) -> Bool {
        return parentChildMap[parent] != nil
    }

    func clearTags() {
        parentChildMap.removeAll()
        allIdValueMap.removeAll()
        parentValueIdMap.removeAll()
        parentChildValueIdMap.removeAll()

        save()
    }

    // swiftlint:disable cyclomatic_complexity
    func renameTag(_ oldValue: String, to newValue: String, of parent: String? = nil) throws -> Tag {
        let isParent = parent == nil
        let ret: Tag // Return value

        // Strategy:
        // 1) Guard against Tag not existing
        // 2) Guard against newValue already existing
        // 3) Update data stores

        if isParent {
            guard parentChildMap[oldValue] != nil else {
                throw InvalidTagError(message: "Parent tag \(oldValue) does not exist")
            }
            guard parentChildMap[newValue] == nil else {
                throw DuplicateTagError(message: "Parent tag \(newValue) already exists")
            }

            // parentChildMap: Update to reflect renaming
            guard let childrenTagValues = parentChildMap[oldValue] else {
                fatalError("This should never happen") // We guarded against this
            }
            parentChildMap[newValue] = childrenTagValues
            parentChildMap[oldValue] = nil

            // allIdValueMap: Update ID to display value mapping
            guard let uid = parentValueIdMap[oldValue] else {
                fatalError("This should never happen")
            }
            allIdValueMap[uid] = newValue

            // parentValueIdMap: Update display value to ID mapping
            parentValueIdMap[oldValue] = nil
            parentValueIdMap[newValue] = uid

            // No need to update parentChildValueIdMap :)

            ret = Tag(uid, parentInternalValue: nil)
        } else { // Is child Tag
            guard let parentDisplayValue = parent else {
                fatalError("This should never happen")
            }
            guard let childrenTagValues = parentChildMap[parentDisplayValue] else {
                throw InvalidTagError(message: "Parent tag \(parentDisplayValue) does not exist")
            }
            guard childrenTagValues.contains(oldValue) else {
                throw InvalidTagError(message: "Child tag \(oldValue) does not exist")
            }
            guard !childrenTagValues.contains(newValue) else {
                throw DuplicateTagError(message: "Child tag \(newValue) already exists")
            }

            // parentChildMap: Update to reflect renaming
            parentChildMap[parentDisplayValue]?.remove(oldValue)
            parentChildMap[parentDisplayValue]?.insert(newValue)

            // allIdValueMap: Update ID to display value mapping
            guard let parentId = parentValueIdMap[parentDisplayValue] else {
                fatalError("This should never happen")
            }
            guard let uid = parentChildValueIdMap[parentId]?[oldValue] else {
                fatalError("This should never happen")
            }
            allIdValueMap[uid] = newValue

            // No need to update parentValueIdMap :)

            // parentChildValueIdMap: Update display value to ID mapping
            parentChildValueIdMap[parentId]?[oldValue] = nil
            parentChildValueIdMap[parentId]?[newValue] = uid

            ret = Tag(uid, parentInternalValue: parentId)
        }

        save()
        return ret
    }
    // swiftlint:enable cyclomatic_complexity
}

// MARK: TagManager: TagValueSourceInterface
extension TagManager: TagValueSourceInterface {

    func getDisplayValue(of internalValue: String) -> String {
        guard let val = allIdValueMap[internalValue] else {
            fatalError("This should never happen")
        }

        return val
    }

}

// MARK: TagManager: persistence
extension TagManager {

    /// Saves the current state of the TagManager object to storage.
    private func save() {
        do {
            log.info("Saving TagManager to storage.")
            let fsm = FileStorageManager()
            let fileName = inTestMode ? TagManager.saveFileNameTest : TagManager.saveFileName
            try fsm.writeAsJson(data: self, as: fileName)
        } catch {
            log.error("Error encountered: \(error)")
        }
    }

}

// MARK: TagManager: private utility methods
extension TagManager {

    /// Creates and returns a Tag. This method automtatically updates data stores and saves to disk.
    /// - Requires: The Tag being created must not already exist.
    private func createTag(_ displayValue: String, of parentDisplayValue: String? = nil) -> Tag {
        let uid = UUID().uuidString

        allIdValueMap[uid] = displayValue

        let isParentTag = parentDisplayValue == nil

        if isParentTag {
            parentChildMap[displayValue] = []
            parentValueIdMap[displayValue] = uid
            parentChildValueIdMap[uid] = [:]

            save()
            return Tag(uid, parentInternalValue: nil)
        } else { // If child Tag
            guard let parentValue = parentDisplayValue else {
                fatalError("This should never happen")
            }
            parentChildMap[parentValue]?.insert(displayValue)
            guard let parentId = parentValueIdMap[parentValue] else {
                fatalError("This should never happen")
            }
            parentChildValueIdMap[parentId]?[displayValue] = uid

            save()
            return Tag(uid, parentInternalValue: parentId)
        }
    }

    /// Removes a Tag. This method automatically updates data stores and saves to disk.
    /// If a parent Tag is removed, all of its children Tags will be removed too.
    /// - Requires: The Tag being removed must exist.
    @discardableResult
    private func removeTag(_ displayValue: String,
                           of parentDisplayValue: String? = nil) throws -> [Tag] {
        let removedTag: Tag
        var removedTags: [Tag] = []
        removedTag = try getTag(for: displayValue, of: parentDisplayValue)
        removedTags.append(removedTag)

        let isParentTag = parentDisplayValue == nil
        if isParentTag {
            guard let uid = parentValueIdMap[displayValue] else {
                fatalError("This should never happen")
            }

            // Remove all children Tags
            removedTags.append(contentsOf: try getChildrenTags(of: displayValue))
            guard let childrenTagValues = parentChildMap[displayValue] else {
                fatalError("This should never happen")
            }
            for childTagValue in childrenTagValues {
                try removeTag(childTagValue, of: displayValue)
            }

            parentValueIdMap[displayValue] = nil
            allIdValueMap[uid] = nil
            parentChildMap[displayValue] = nil
            parentChildValueIdMap[uid] = nil
        } else { // If child Tag
            guard let parentDisplayValue = parentDisplayValue else {
                fatalError("This should never happen")
            }
            guard let parentId = parentValueIdMap[parentDisplayValue] else {
                fatalError("This should never happen")
            }
            guard let uid = parentChildValueIdMap[parentId]?[displayValue] else {
                fatalError("This should never happen")
            }

            allIdValueMap[uid] = nil
            parentChildMap[parentDisplayValue]?.remove(displayValue)
            parentChildValueIdMap[parentId]?[displayValue] = nil
        }

        save()
        return removedTags
    }

}
// swiftlint:enable file_length
