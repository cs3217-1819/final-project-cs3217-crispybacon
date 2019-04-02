//
//  ObserverTests.swift
//  baconTests
//
//  Created by Fabian Terh on 27/3/19.
//  Copyright © 2019 nus.CS3217. All rights reserved.
//

import Foundation

import XCTest
@testable import bacon

class DummyObserver: Observer {
    var notifiedCount = 0

    func notify(_ value: Any) {
        notifiedCount += 1
    }
}

class DummyObservable: Observable {
    var observers: [Observer] = []
}

class ObserverTests: XCTestCase {

    // Each test case includes logic for the following methods in Observable:
    // - registerObserver
    // - notifyObservers
    // - unregisterObserver

    func test_oneObservable_oneObserver() {
        let observer = DummyObserver()
        let observable = DummyObservable()

        observable.registerObserver(observer)
        XCTAssertEqual(observer.notifiedCount, 0)
        observable.notifyObservers("")
        XCTAssertEqual(observer.notifiedCount, 1)
        observable.unregisterObserver(observer)
        observable.notifyObservers("")
        XCTAssertEqual(observer.notifiedCount, 1)
    }

    func test_oneObservable_multipleObservers() {
        let observer1 = DummyObserver()
        let observer2 = DummyObserver()
        let observable = DummyObservable()

        observable.registerObserver(observer1)
        observable.registerObserver(observer2)
        XCTAssertEqual(observer1.notifiedCount, 0)
        XCTAssertEqual(observer2.notifiedCount, 0)
        observable.notifyObservers("")
        XCTAssertEqual(observer1.notifiedCount, 1)
        XCTAssertEqual(observer2.notifiedCount, 1)
        observable.unregisterObserver(observer1)
        observable.notifyObservers("")
        XCTAssertEqual(observer1.notifiedCount, 1)
        XCTAssertEqual(observer2.notifiedCount, 2)
    }

}
