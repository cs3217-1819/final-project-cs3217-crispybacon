//
//  TagManagerTests.swift
//  baconTests
//
//  Created by Fabian Terh on 11/4/19.
//  Copyright © 2019 nus.CS3217. All rights reserved.
//

// swiftlint:disable force_try

import XCTest
@testable import bacon

class TagManagerTests: XCTestCase {

    var tagManager = TagManager()

    let parent1 = "parent1"
    let parent2 = "parent2"
    let child1 = "child1"
    let child2 = "child2"

    override func setUp() {
        tagManager = TagManager() // Reset to fresh instance
    }

    func test_addChildTag_parentTagExists() {
        try! tagManager.addParentTag(parent1)
        XCTAssertFalse(tagManager.isChildTag(child1, of: parent1))

        try! tagManager.addChildTag(child1, to: parent1)
        XCTAssertTrue(tagManager.isChildTag(child1, of: parent1))
    }

    func test_addChildTag_parentTagDoesNotExist() {
        XCTAssertFalse(tagManager.isParentTag(parent1))
        XCTAssertFalse(tagManager.isChildTag(child1, of: parent1))

        try! tagManager.addChildTag(child1, to: parent1)
        XCTAssertTrue(tagManager.isParentTag(parent1))
        XCTAssertTrue(tagManager.isChildTag(child1, of: parent1))
    }

    func test_addChildTag_duplicateTags() {
        try! tagManager.addChildTag(child1, to: parent1)
        XCTAssertThrowsError(try tagManager.addChildTag(child1, to: parent1)) { err in
            XCTAssertTrue(err is DuplicateTagError)
        }
    }

    func test_addChildTag_multipleParents() {
        try! tagManager.addParentTag(parent1)
        try! tagManager.addParentTag(parent2)
        XCTAssertEqual(try! tagManager.getChildrenTagsOf(parent1).count, 0)
        XCTAssertEqual(try! tagManager.getChildrenTagsOf(parent2).count, 0)

        try! tagManager.addChildTag(child1, to: parent1)
        XCTAssertEqual(try! tagManager.getChildrenTagsOf(parent1).count, 1)
        XCTAssertEqual(try! tagManager.getChildrenTagsOf(parent2).count, 0)

        try! tagManager.addChildTag(child2, to: parent1)
        XCTAssertEqual(try! tagManager.getChildrenTagsOf(parent1).count, 2)
        XCTAssertEqual(try! tagManager.getChildrenTagsOf(parent2).count, 0)

        try! tagManager.addChildTag(child1, to: parent2)
        XCTAssertEqual(try! tagManager.getChildrenTagsOf(parent1).count, 2)
        XCTAssertEqual(try! tagManager.getChildrenTagsOf(parent2).count, 1)

        try! tagManager.addChildTag(child2, to: parent2)
        XCTAssertEqual(try! tagManager.getChildrenTagsOf(parent1).count, 2)
        XCTAssertEqual(try! tagManager.getChildrenTagsOf(parent2).count, 2)
    }

    func test_addParentTag_noDuplicateTags() {
        XCTAssertFalse(tagManager.isParentTag(parent1))
        try! tagManager.addParentTag(parent1)
        XCTAssertTrue(tagManager.isParentTag(parent1))
    }

    func test_addParentTag_duplicateTags() {
        try! tagManager.addParentTag(parent1)
        XCTAssertThrowsError(try tagManager.addParentTag(parent1)) { err in
            XCTAssertTrue(err is DuplicateTagError)
        }
    }

    func test_addParentTag_multipleTags() {
        XCTAssertFalse(tagManager.isParentTag(parent1))
        XCTAssertFalse(tagManager.isParentTag(parent2))
        try! tagManager.addParentTag(parent1)
        try! tagManager.addParentTag(parent2)
        XCTAssertTrue(tagManager.isParentTag(parent1))
        XCTAssertTrue(tagManager.isParentTag(parent2))
    }

    func test_removeChildTag_parentTagExists() {
        XCTAssertFalse(tagManager.isChildTag(child1, of: parent1))
        try! tagManager.addParentTag(parent1)
        try! tagManager.addChildTag(child1, to: parent1)
        XCTAssertTrue(tagManager.isChildTag(child1, of: parent1))

        try! tagManager.removeChildTag(child1, from: parent1)
        XCTAssertFalse(tagManager.isChildTag(child1, of: parent1))
    }

    func test_removeChildTag_parentTagDoesNotExist() {
        try! tagManager.addParentTag(parent1)
        try! tagManager.addParentTag(parent2)
        try! tagManager.addChildTag(child1, to: parent1)
        XCTAssertThrowsError(try tagManager.removeChildTag(child1, from: parent2)) { err in
            XCTAssertTrue(err is InvalidTagError)
        }
    }

    func test_removeChildTag_childTagDoesNotExist() {
        try! tagManager.addParentTag(parent1)
        try! tagManager.addChildTag(child1, to: parent1)
        XCTAssertThrowsError(try tagManager.removeChildTag(child2, from: parent1)) { err in
            XCTAssertTrue(err is InvalidTagError)
        }
    }

    func test_removeChildTag_multipleParentTags() {
        try! tagManager.addParentTag(parent1)
        try! tagManager.addParentTag(parent2)
        try! tagManager.addChildTag(child1, to: parent1)
        try! tagManager.addChildTag(child1, to: parent2)
        XCTAssertTrue(tagManager.isChildTag(child1, of: parent1))
        XCTAssertTrue(tagManager.isChildTag(child1, of: parent2))

        try! tagManager.removeChildTag(child1, from: parent1)
        XCTAssertFalse(tagManager.isChildTag(child1, of: parent1))
        XCTAssertTrue(tagManager.isChildTag(child1, of: parent2))
    }

    func test_removeParentTag_exists() {
        try! tagManager.addParentTag(parent1)
        XCTAssertTrue(tagManager.isParentTag(parent1))
        try! tagManager.removeParentTag(parent1)
        XCTAssertFalse(tagManager.isParentTag(parent1))
    }
    func test_removeParentTag_doesNotExist() {
        try! tagManager.addParentTag(parent1)
        XCTAssertThrowsError(try tagManager.removeParentTag(parent2)) { err in
            XCTAssertTrue(err is InvalidTagError)
        }
    }

    func test_removeParentTag_hasChildrenTags() {
        try! tagManager.addParentTag(parent1)
        try! tagManager.addChildTag(child1, to: parent1)
        try! tagManager.addChildTag(child2, to: parent1)
        XCTAssertTrue(tagManager.isChildTag(child1, of: parent1))
        XCTAssertTrue(tagManager.isChildTag(child2, of: parent1))

        try! tagManager.removeParentTag(parent1)
        XCTAssertFalse(tagManager.isParentTag(parent1))
        XCTAssertFalse(tagManager.isChildTag(child1, of: parent1))
        XCTAssertFalse(tagManager.isChildTag(child2, of: parent1))
    }

    func test_removeParentTag_multipleParentTags() {
        try! tagManager.addParentTag(parent1)
        try! tagManager.addParentTag(parent2)
        XCTAssertTrue(tagManager.isParentTag(parent1))
        XCTAssertTrue(tagManager.isParentTag(parent2))

        try! tagManager.removeParentTag(parent1)
        XCTAssertFalse(tagManager.isParentTag(parent1))
        XCTAssertTrue(tagManager.isParentTag(parent2))
    }

    func test_getChildrenTagsOf_noChildrenTags() {
        try! tagManager.addParentTag(parent1)
        XCTAssertEqual(try! tagManager.getChildrenTagsOf(parent1).count, 0)
    }

    func test_getChildrenTagsOf_multipleChildrenTags() {
        try! tagManager.addParentTag(parent1)
        try! tagManager.addChildTag(child1, to: parent1)
        try! tagManager.addChildTag(child2, to: parent1)
        XCTAssertEqual(try! tagManager.getChildrenTagsOf(parent1).count, 2)
    }

    func test_getChildrenTagsOf_parentTagDoesNotExist() {
        try! tagManager.addParentTag(parent1)
        try! tagManager.addChildTag(child1, to: parent1)
        try! tagManager.addChildTag(child2, to: parent1)
        XCTAssertThrowsError(try tagManager.getChildrenTagsOf(parent2)) { err in
            XCTAssertTrue(err is InvalidTagError)
        }
    }

    func test_getParentTags_noParentTags() {
        XCTAssertEqual(tagManager.getParentTags().count, 0)
    }

    func test_getParentTags_oneParentTags() {
        try! tagManager.addParentTag(parent1)
        XCTAssertEqual(tagManager.getParentTags().count, 1)
    }
    func test_getParentTags_twoParentTags() {
        try! tagManager.addParentTag(parent1)
        try! tagManager.addParentTag(parent2)
        XCTAssertEqual(tagManager.getParentTags().count, 2)
    }

    func test_isChildTag_parentTagExists() {
        try! tagManager.addParentTag(parent1)
        try! tagManager.addChildTag(child1, to: parent1)
        XCTAssertTrue(tagManager.isChildTag(child1, of: parent1))
    }
    func test_isChildTag_parentTagDoesNotExist() {
        try! tagManager.addParentTag(parent1)
        try! tagManager.addChildTag(child1, to: parent1)
        XCTAssertFalse(tagManager.isChildTag(child1, of: parent2))
    }

    func test_isParentTag_parentTagExists() {
        try! tagManager.addParentTag(parent1)
        XCTAssertTrue(tagManager.isParentTag(parent1))
    }
    func test_isParentTag_parentTagDoesNotExist() {
        try! tagManager.addParentTag(parent1)
        XCTAssertFalse(tagManager.isParentTag(parent2))
    }


}

// swiftlint:enbable force_try
