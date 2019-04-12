//
//  TagManager.swift
//  bacon
//
//  Created by Fabian Terh on 10/4/19.
//  Copyright © 2019 nus.CS3217. All rights reserved.
//

import Foundation

// MARK: TagManager: TagManagerInterface
class TagManager: Codable, Observable, TagManagerInterface {

    // Support persistence
    private static let saveFileName = "TagManager"
    private static let errorLoadData = "Loading of TagManager data failed"
    private static var cachedPersistentTagManager: TagManager?
    private var isPersistent: Bool

    // Set of all Tags (both parent and child Tags). Use for membership check.
    private var allTags: Set<Tag> = []

    // Map of parent Tags to child Tags. Use for parent-child association check.
    private var parentChildMap: [Tag: Set<Tag>] = [:]

    // Observable
    var observers: [Observer] = []

    // See: https://developer.apple.com/documentation/foundation/archives_and_serialization/encoding_and_decoding_custom_types
    // We exclude the "observers" property from being encoded/decoded,
    // since that information should not be persistent across sessions.
    private enum CodingKeys: String, CodingKey {
        case isPersistent
        case allTags
        case parentChildMap
    }

    /// Creates and returns a TagManager object.
    /// - Note: A persistent TagManager is implemented as a singleton, and thus will never be outdated.
    /// - Parameter withPersistence: If `true`, changes to TagManager data (e.g. add/remove Tags) will
    ///     automatically be saved to storage. The TagManager object returned will also be pre-loaded
    ///     with pre-existing data. If `false`, the TagManager object returned will only manage Tags in memory.
    static func create(withPersistence: Bool) -> TagManager {
        log.info("Creating TagManager withPersistence=\(withPersistence).")

        // Without persistence
        if !withPersistence {
            log.info("Returning non-persistent instance of TagManager.")
            return TagManager(withPersistence: false)
        }

        // With persistence: if a persistent TagManager has previously been instantiated,
        // we return it. Otherwise, we create a new instance and cache it.
        if let tagManager = TagManager.cachedPersistentTagManager {
            log.info("Returning cached instance of persistent TagManager.")
            return tagManager
        }

        log.info("No cached instance of persistent TagManager found. Instantiating TagManager.")
        let fsm = FileStorageManager()
        let tagManager: TagManager

        do {
            log.info("Reading TagManager data from storage.")
            tagManager = try fsm.readFromJson(TagManager.self, file: TagManager.saveFileName)
            log.info("TagManager reconstructed from storage data")
        } catch {
            // This could happen if a persistent TagManager is instantiated for the first time ever
            log.warning("\(TagManager.errorLoadData). Instantiating a new instance.")
            tagManager = TagManager(withPersistence: true)
            TagManager.cachedPersistentTagManager = tagManager
            return tagManager
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
    private init(withPersistence: Bool) {
        isPersistent = withPersistence
    }

    func addChildTag(_ child: String, to parent: String) throws {
        let childTag = Tag(child, parent: parent)
        let parentTag = Tag(parent)

        // childTag should not already exist
        guard !allTags.contains(childTag) else {
            throw DuplicateTagError(message: "\(childTag) already exists")
        }

        // parentTag should already exist
        guard allTags.contains(parentTag) else {
            throw InvalidTagError(message: "\(parentTag) does not exist")
        }

        addTags([childTag, parentTag])
    }

    func addParentTag(_ parent: String) throws {
        let parentTag = Tag(parent)

        // parentTag should not already exist
        guard !allTags.contains(parentTag) else {
            throw DuplicateTagError(message: "\(parentTag) already exists")
        }

        addTags([parentTag])

    }

    func removeChildTag(_ child: String, from parent: String) throws {
        let childTag = Tag(child, parent: parent)
        let parentTag = Tag(parent)

        // childTag should exist
        guard allTags.contains(childTag) else {
            throw InvalidTagError(message: "\(childTag) does not exist")
        }

        // parentTag should exist
        guard allTags.contains(parentTag) else {
            throw InvalidTagError(message: "\(parentTag) does not exist")
        }

        removeTags([childTag])
    }

    func removeParentTag(_ parent: String) throws {
        let parentTag = Tag(parent)

        // parentTag should exist
        guard allTags.contains(parentTag) else {
            throw InvalidTagError(message: "\(parentTag) does not exist")
        }

        removeTags([parentTag])
    }

    var tags: [Tag: [Tag]] {
        var ret: [Tag: [Tag]] = [:]
        for parentTag in parentChildMap.keys {
            guard let setChildrenTags = parentChildMap[parentTag] else {
                fatalError("This should never happen")
            }
            var arrChildrenTags = Array(setChildrenTags)
            arrChildrenTags.sort()
            ret[parentTag] = arrChildrenTags
        }

        return ret
    }

    var parentTags: [Tag] {
        var arrParentTags = Array(parentChildMap.keys)
        arrParentTags.sort()
        return arrParentTags
    }

    func getChildrenTagsOf(_ parent: String) throws -> [Tag] {
        let parentTag = Tag(parent)

        // parentTag should exist
        guard allTags.contains(parentTag) else {
            throw InvalidTagError(message: "\(parentTag) does not exist")
        }

        guard let setChildrenTags = parentChildMap[parentTag] else {
            // If parentTag exists, it should minimally be mapped to an empty set
            fatalError("This should never happen")
        }

        var arrChildrenTags = Array(setChildrenTags)
        arrChildrenTags.sort()
        return arrChildrenTags
    }

    func isChildTag(_ child: String, of parent: String) -> Bool {
        let childTag = Tag(child, parent: parent)
        let parentTag = Tag(parent)

        // parentTag should exist
        guard allTags.contains(parentTag) else {
            return false
        }

        return allTags.contains(childTag)
    }

    func isParentTag(_ parent: String) -> Bool {
        let parentTag = Tag(parent)
        return allTags.contains(parentTag)
    }

}

// MARK: TagManager: persistence
extension TagManager {

    /// Saves the current state of the TagManager object to storage.
    private func save() {
        do {
            log.info("Saving TagManager to storage.")
            let fsm = FileStorageManager()
            try fsm.writeAsJson(data: self, as: TagManager.saveFileName)
        } catch {
            log.error("Error encountered: \(error)")
        }
    }

}

// MARK: TagManager private utility methods
extension TagManager {

    /// Adds multiple Tags into both the `allTags` set and `parentChildMap` dictionary.
    /// This method automatically detects and handles parent/child Tags accordingly.
    /// If a child Tag's parent does not already exist, it will be created automatically.
    private func addTags(_ tags: [Tag]) {
        for tag in tags {
            // Update parentChildMap
            if let parent = tag.parent { // `tag` is a child Tag
                let parentTag = Tag(parent)

                // Create parent Tag if it doesn't already exist
                if parentChildMap[parentTag] == nil {
                    parentChildMap[parentTag] = []
                }

                parentChildMap[parentTag]?.insert(tag)
            } else { // `tag` is a parent Tag
                // Create parent Tag if it doesn't already exist
                if parentChildMap[tag] == nil {
                    parentChildMap[tag] = []
                }
            }

            // Add to allTags
            allTags.insert(tag)
        }

        if isPersistent {
            save()
        }
    }

    /// Removes multiple Tags from both the `allTags` set and `parentChildMap` dictionary.
    /// This method automatically detects and handles parent/child Tags accordingly.
    /// If a parent Tag has children, all of its children Tags will also be removed.
    /// - Note: Does nothing if a Tag does not exist.
    private func removeTags(_ tags: [Tag]) {
        for tag in tags {
            // Update parentChildMap
            if let parent = tag.parent { // `tag` is a child Tag
                let parentTag = Tag(parent)
                parentChildMap[parentTag]?.remove(tag)
            } else { // `tag` is a parent Tag
                // Remove all children Tags
                guard let childrenTags = parentChildMap[tag] else {
                    fatalError("This should never happen")
                }
                let arrChildrenTags = Array(childrenTags)
                removeTags(arrChildrenTags)

                // Remove current (parent) Tag
                parentChildMap.removeValue(forKey: tag)
            }

            // Remove from allTags
            allTags.remove(tag)
        }

        if isPersistent {
            save()
        }
    }

}
