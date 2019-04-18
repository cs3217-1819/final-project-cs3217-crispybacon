//
//  TagValueSourceInterface.swift
//  bacon
//
//  Created by Fabian Terh on 12/4/19.
//  Copyright © 2019 nus.CS3217. All rights reserved.
//

import Foundation

protocol TagValueSourceInterface: Codable {

    /// Returns the (external) display value of a Tag's internal value.
    func getDisplayValue(of internalValue: Int64) -> String

}
