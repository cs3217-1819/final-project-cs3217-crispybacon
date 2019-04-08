//
//  HashableClass.swift
//  bacon
//
//  Created by Fabian Terh on 7/4/19.
//  Copyright © 2019 nus.CS3217. All rights reserved.
//

import Foundation

/// A Hashable superclass for instant conformance to the Hashable protocol.
/// - Note: Hash values are derived from the instance's object identifier.
///     == is overridden to return === instead.
///     If instance properties comparison is required, consider implementing an `equals()` method instead.
class HashableClass: Equatable, Hashable {

    static func == (lhs: HashableClass, rhs: HashableClass) -> Bool {
        return lhs === rhs
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }

}
