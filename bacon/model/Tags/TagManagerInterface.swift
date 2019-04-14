//
//  TagManagerInterface.swift
//  bacon
//
//  Created by Fabian Terh on 10/4/19.
//  Copyright © 2019 nus.CS3217. All rights reserved.
//

import Foundation

struct DuplicateTagError: Error {
    let message: String
}

struct InvalidTagError: Error {
    let message: String
}

protocol TagManagerInterface: Observable {

    /// Adds a new child Tag to a parent Tag and returns it.
    /// - Throws:
    ///     - `DuplicateTagError` if the child Tag already exists.
    ///     - `InvalidTagError` if the parent Tag does not exist.
    func addChildTag(_ child: String, to parent: String) throws -> Tag

    /// Adds a new parent Tag and returns it.
    /// - Throws: `DuplicateTagError` if the Tag already exists.
    func addParentTag(_ parent: String) throws -> Tag

    /// Removes a child Tag from a parent Tag.
    /// - Throws: `InvalidTagError` if either Tag does not exist.
    func removeChildTag(_ child: String, from parent: String) throws

    /// Removes a parent Tag. All of its children Tags will be removed too.
    /// - Throws: `InvalidTagError` if the Tag does not exist.
    func removeParentTag(_ parent: String) throws

    /// Contains all Tags in a dictionary mapping parent Tags to sorted arrays of their children Tags.
    var tags: [Tag: [Tag]] { get }

    /// Contains a sorted array of all existing parent Tags.
    var parentTags: [Tag] { get }

    /// Returns a sorted array of the children Tags of a parent Tag.
    /// - Throws: `InvalidTagError` if the parent Tag does not exist.
    func getChildrenTags(of parent: String) throws -> [Tag]

    /// Checks whether a child Tag exists.
    /// A child Tag exists when its parent Tag exists and they are associated.
    func isChildTag(_ child: String, of parent: String) -> Bool

    /// Checks whether a parent Tag with the provided value exists.
    func isParentTag(_ parent: String) -> Bool

    /// Clears all Tags.
    func clearTags()

}
