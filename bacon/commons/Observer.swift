//
//  Observer.swift
//  bacon
//
//  Created by Fabian Terh on 27/3/19.
//  Copyright © 2019 nus.CS3217. All rights reserved.
//

import Foundation

/// Observer protocol in the Observer-Subject pattern.
/// - Note: This protocol only allows conformance by classes,
/// as `unregisterObserver()` in Observable makes use of identity comparison.
protocol Observer: class {

    /// Receives notification of a value published by the observed subject.
    /// Since `value` is typed as `Any`, the observer is responsible for casting `value` to
    /// the correct type of whatever it is observing.
    func notify(_ value: Any)

}
