//
//  Tag.swift
//  bacon
//
//  Created by Fabian Terh on 10/4/19.
//  Copyright © 2019 nus.CS3217. All rights reserved.
//

import Foundation

/// Tag ADT to represent a transaction tag.
/// A Tag has a value, and an optional parent value.
/// A Tag must be either a parent or child Tag.
struct Tag: Codable, Equatable, Hashable {

    let value: String
    let parent: String?

    /// Initializes a parent Tag.
    init(_ value: String) {
        self.init(value, parent: nil)
    }

    /// Initializes a child Tag.
    init(_ value: String, parent: String?) {
        self.value = value
        self.parent = parent
    }

    /// Convenience computed property to represent whether a Tag is a child Tag.
    var isChild: Bool {
        return parent != nil
    }

    /// Convenience computed property to represent whether a Tag is a parent Tag.
    var isParent: Bool {
        return !isChild
    }

}
