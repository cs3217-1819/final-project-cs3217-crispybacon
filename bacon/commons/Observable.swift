//
//  Observable
//  bacon
//
//  Created by Fabian Terh on 27/3/19.
//  Copyright © 2019 nus.CS3217. All rights reserved.
//

import Foundation

/// Observable (Subject) protocol in the Observer-Subject pattern.
protocol Observable {

    var observers: [Observer] { get set }

}

/// Implement default functionality for Observable protocol.
extension Observable {

    /// Registers an observer to the current observable subject.
    mutating func registerObserver(_ observer: Observer) {
        observers.append(observer)
    }

    /// Unregisters an observer to the current observable subject.
    /// - Requires: `observer` must be a Class type.
    mutating func unregisterObserver(_ observer: Observer) {
        observers = observers.filter { $0 !== observer }
    }

    func notifyObservers<T>(value: T) {
        for observer in observers {
            observer.notify(value)
        }
    }

}
