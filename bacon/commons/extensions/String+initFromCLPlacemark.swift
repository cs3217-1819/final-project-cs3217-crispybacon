//
//  String+initFromCLPlacemark.swift
//  bacon
//
//  Created by Lizhi Zhang on 2/4/19.
//  Copyright © 2019 nus.CS3217. All rights reserved.
//

import Foundation
import CoreLocation
import Contacts

extension String {
    init?(_ placeMark: CLPlacemark) {
        self.init(CNPostalAddressFormatter().string(from: placeMark.postalAddress ?? Constants.defaultPostalAddress))
    }
}
