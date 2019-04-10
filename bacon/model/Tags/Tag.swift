//
//  Tag.swift
//  bacon
//
//  Created by Fabian Terh on 10/4/19.
//  Copyright © 2019 nus.CS3217. All rights reserved.
//

import Foundation

struct Tag: Codable, Equatable, Hashable {

    let value: String
    let parent: String?

    init(_ value: String) {
        self.init(value, parent: nil)
    }

    init(_ value: String, parent: String?) {
        self.value = value
        self.parent = parent
    }

}
