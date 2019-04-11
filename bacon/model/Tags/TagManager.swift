//
//  TagManager.swift
//  bacon
//
//  Created by Fabian Terh on 10/4/19.
//  Copyright © 2019 nus.CS3217. All rights reserved.
//

import Foundation

// MARK: TagManager: TagManagerInterface
class TagManager: TagManagerInterface {

    // Set of all Tags (both parent and child Tags). Use for membership check.
    private var allTags: Set<Tag> = []

    // Map of parent Tags to child Tags. Use for parent-child association check.
    private var parentChildMap: [Tag: Set<Tag>] = [:]

    func addChildTag(_ child: String, to parent: String) throws {
        let childTag = Tag(child, parent: parent)
        let parentTag = Tag(parent)

        // childTag should not already exist
        guard !allTags.contains(childTag) else {
            throw DuplicateTagError(message: "\(childTag) already exists")
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

    var tags: [Tag: Set<Tag>] {
        return parentChildMap
    }

    func getChildrenTagsOf(_ parent: String) throws -> Set<Tag> {
        let parentTag = Tag(parent)

        // parentTag should exist
        guard allTags.contains(parentTag) else {
            throw InvalidTagError(message: "\(parentTag) does not exist")
        }

        guard let childrenTags = parentChildMap[parentTag] else {
            // If parentTag exists, it should minimally be mapped to an empty set
            fatalError("This should never happen")
        }

        return childrenTags
    }

    func getParentTags() -> Set<Tag> {
        return Set(parentChildMap.keys)
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
                let arrChildren = parentChildMap[tag]?.map { return $0 } ?? []
                removeTags(arrChildren)

                // Remove current (parent) Tag
                parentChildMap.removeValue(forKey: tag)
            }

            // Remove from allTags
            allTags.remove(tag)
        }
    }

}
