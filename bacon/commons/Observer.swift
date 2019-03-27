//
//  Observer.swift
//  bacon
//
//  Created by Fabian Terh on 27/3/19.
//  Copyright © 2019 nus.CS3217. All rights reserved.
//

import Foundation

/// Observer protocol in the Observer-Subject pattern.
/// This protocol may only be conformed to by classes.
protocol Observer: class {

    /// Receives notification of a value published by the observed subject.
    func notify<T>(_ value: T)

}
