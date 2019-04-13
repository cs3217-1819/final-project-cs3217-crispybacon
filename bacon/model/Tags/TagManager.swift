//
//  TagManager.swift
//  bacon
//
//  Created by Fabian Terh on 10/4/19.
//  Copyright © 2019 nus.CS3217. All rights reserved.
//

import Foundation

// MARK: Tag
struct Tag: Codable, Comparable, Hashable {

    let internalValue: Int64 // Internal value of the Tag
    let parentInternalValue: Int64? // Internal value of parent Tag

    /// Returns the user-defined display value of a Tag, or an empty string if unavailable.
    /// The only period of unavailablility is when TagManager has not been fully instantiated.
    /// It should never be unavailable in normal usage.
    var value: String {
        if TagManager.inTestMode {
            return TagManager.cachedPersistentTagManagerTest?.getDisplayValue(of: internalValue) ?? ""
        } else {
            return TagManager.cachedPersistentTagManager?.getDisplayValue(of: internalValue) ?? ""
        }
    }

    /// Returns the user-defined display value of a Tag's parent.
    /// Returns `nil` if a Tag does not have a parent, or an empty string if unavailable.
    /// The only period of unavailablility is when TagManager has not been fully instantiated.
    /// It should never be unavailable in normal usage.
    var parentValue: String? {
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

    private enum CodingKeys: String, CodingKey {
        case internalValue
        case parentInternalValue
    }

    /// Initializes a Tag.
    fileprivate init(_ internalValue: Int64, parentInternalValue: Int64?) {
        self.internalValue = internalValue
        self.parentInternalValue = parentInternalValue
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
        return lhs.value == rhs.value && lhs.parentValue == rhs.parentValue
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
        hasher.combine(value)
        hasher.combine(parentValue)
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
    private var tagId: Int64 = 1
    private var parentChildMap: [String: Set<String>] = [:] // Map parent to child Tags by display values
    private var allIdValueMap: [Int64: String] = [:] // Map all IDs to display values
    private var parentValueIdMap: [String: Int64] = [:] // Map only parent display values to IDs
    private var parentChildValueIdMap: [Int64: [String: Int64]] = [:] // Map children Tag display values to IDs

    // Observable
    var observers: [Observer] = []

    // See: https://developer.apple.com/documentation/foundation/archives_and_serialization/encoding_and_decoding_custom_types
    // We exclude the "observers" property from being encoded/decoded,
    // since that information should not be persistent across sessions.
    private enum CodingKeys: String, CodingKey {
        case inTestMode
        case tagId
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

    func removeChildTag(_ child: String, from parent: String) throws {
        // Parent Tag should exist
        guard let children = parentChildMap[parent] else {
            throw InvalidTagError(message: "Parent tag \(parent) does not exist")
        }

        // Child Tag should exist
        guard children.contains(child) else {
            throw InvalidTagError(message: "Child tag \(child) does not exist")
        }

        removeTag(child, of: parent)
    }

    func removeParentTag(_ parent: String) throws {
        // Parent Tag should exist
        guard parentChildMap[parent] != nil else {
            throw InvalidTagError(message: "Parent tag \(parent) does not exist")
        }

        removeTag(parent)
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

}

// MARK: TagManager: TagValueSourceInterface
extension TagManager: TagValueSourceInterface {

    func getDisplayValue(of internalValue: Int64) -> String {
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
        let id = tagId
        tagId += 1

        allIdValueMap[id] = displayValue

        let isParentTag = parentDisplayValue == nil

        if isParentTag {
            parentChildMap[displayValue] = []
            parentValueIdMap[displayValue] = id
            parentChildValueIdMap[id] = [:]

            save()
            return Tag(id, parentInternalValue: nil)
        } else { // If child Tag
            guard let parentValue = parentDisplayValue else {
                fatalError("This should never happen")
            }
            parentChildMap[parentValue]?.insert(displayValue)
            guard let parentId = parentValueIdMap[parentValue] else {
                fatalError("This should never happen")
            }
            parentChildValueIdMap[parentId]?[displayValue] = id

            save()
            return Tag(id, parentInternalValue: parentId)
        }
    }

    /// Removes a Tag. This method automatically updates data stores and saves to disk.
    /// If a parent Tag is removed, all of its children Tags will be removed too.
    /// - Requires: The Tag being removed must exist.
    private func removeTag(_ displayValue: String, of parentDisplayValue: String? = nil) {
        let isParentTag = parentDisplayValue == nil
        if isParentTag {
            guard let id = parentValueIdMap[displayValue] else {
                fatalError("This should never happen")
            }

            // Remove all children Tags
            guard let childrenTagValues = parentChildMap[displayValue] else {
                fatalError("This should never happen")
            }
            for childTagValue in childrenTagValues {
                removeTag(childTagValue, of: displayValue)
            }

            parentValueIdMap[displayValue] = nil
            allIdValueMap[id] = nil
            parentChildMap[displayValue] = nil
            parentChildValueIdMap[id] = nil
        } else { // If child Tag
            guard let parentDisplayValue = parentDisplayValue else {
                fatalError("This should never happen")
            }
            guard let parentId = parentValueIdMap[parentDisplayValue] else {
                fatalError("This should never happen")
            }
            guard let id = parentChildValueIdMap[parentId]?[displayValue] else {
                fatalError("This should never happen")
            }

            allIdValueMap[id] = nil
            parentChildMap[parentDisplayValue]?.remove(displayValue)
            parentChildValueIdMap[parentId]?[displayValue] = nil
        }

        save()
    }

}