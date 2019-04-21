//
//  Observable
//  bacon
//
//  Created by Fabian Terh on 27/3/19.
//  Copyright © 2019 nus.CS3217. All rights reserved.
//

import Foundation

/// Observable (Subject) protocol in the Observer-Subject pattern.
/// - Note: This protocol only allows conformance by classes.
///     See: https://benoitpasquier.com/observer-design-pattern-swift/
protocol Observable: class {
    var observers: [Observer] { get set }
}

// Implements default functionality for Observable protocol.
extension Observable {
    /// Registers an observer to the current observable subject.
    func registerObserver(_ observer: Observer) {
        observers.append(observer)
    }

    /// Unregisters an observer to the current observable subject.
    func unregisterObserver(_ observer: Observer) {
        observers = observers.filter { $0 !== observer }
    }

    /// Notifies all observers of a value.
    func notifyObservers(_ value: Any) {
        for observer in observers {
            observer.notify(value)
        }
    }
}
