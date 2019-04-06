//
//  CodableCLLocation.swift
//  bacon
//
//  Created by Fabian Terh on 29/3/19.
//  Copyright © 2019 nus.CS3217. All rights reserved.
//

import Foundation
import CoreLocation

// CLLocation doesn't conform to Codable by default.
// We write a CodableCLLocation wrapper for Codable conformance.
//
// Acknowledgement: https://gist.github.com/hishma/7be2361888859e94cd0a898bb33c1383

// MARK: CLLocation: Encodable
/// Extends CLLocation to be Encodable.
extension CLLocation: Encodable {
    enum CodingKeys: String, CodingKey {
        case latitude
        case longitude
        case altitude
        case horizontalAccuracy
        case verticalAccuracy
        case speed
        case course
        case timestamp
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(coordinate.latitude, forKey: .latitude)
        try container.encode(coordinate.longitude, forKey: .longitude)
        try container.encode(altitude, forKey: .altitude)
        try container.encode(horizontalAccuracy, forKey: .horizontalAccuracy)
        try container.encode(verticalAccuracy, forKey: .verticalAccuracy)
        try container.encode(speed, forKey: .speed)
        try container.encode(course, forKey: .course)
        try container.encode(timestamp, forKey: .timestamp)
    }
}

// MARK: CLLocation: Equatable
extension CLLocation {

    // Although CLLocation conforms to Equatable already, it is using NSObject's == function.
    // As a result, 2 CLLocation instances which have the exact properties are considered to be unequal.
    // This method overrides that default implementation to compare instance properties when determining equality.
    // See: https://stackoverflow.com/questions/46207883/how-does-cllocation-implement-the-equatable-protocol
    static func == (lhs: CLLocation, rhs: CLLocation) -> Bool {
        return lhs.coordinate.latitude == rhs.coordinate.latitude
            && lhs.coordinate.longitude == rhs.coordinate.longitude
            && lhs.altitude == rhs.altitude
            && lhs.horizontalAccuracy == rhs.horizontalAccuracy
            && lhs.verticalAccuracy == rhs.verticalAccuracy
            && lhs.speed == rhs.speed
            && lhs.course == rhs.course
            && lhs.timestamp == rhs.timestamp
    }

    // Override the != comparison too to use the negation of ==.
    static func != (lhs: CLLocation, rhs: CLLocation) -> Bool {
        return !(lhs == rhs)
    }

    // We need to override isEqual(), because XCTAssertEqual() calls isEqual on NSObjects.
    // See: https://stackoverflow.com/questions/32500821/xctassertequal-not-working-for-equatable-types-in-swift
    // If we don't, we could get a situation where loc1 == loc2, but XCTAssertEqual(loc1, loc2) fails.
    override open func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? CLLocation else {
            return false
        }

        return self == other
    }

}

// MARK: CodableCLLocation
/// Codable and Equatable wrapper around CLLocation.
struct CodableCLLocation: Codable, Equatable, Hashable {

    let location: CLLocation

    init(_ location: CLLocation) {
        self.location = location
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CLLocation.CodingKeys.self)

        try container.encode(location.coordinate.latitude, forKey: .latitude)
        try container.encode(location.coordinate.longitude, forKey: .longitude)
        try container.encode(location.altitude, forKey: .altitude)
        try container.encode(location.horizontalAccuracy, forKey: .horizontalAccuracy)
        try container.encode(location.verticalAccuracy, forKey: .verticalAccuracy)
        try container.encode(location.speed, forKey: .speed)
        try container.encode(location.course, forKey: .course)
        try container.encode(location.timestamp, forKey: .timestamp)
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CLLocation.CodingKeys.self)

        let latitude = try container.decode(CLLocationDegrees.self, forKey: .latitude)
        let longitude = try container.decode(CLLocationDegrees.self, forKey: .longitude)
        let altitude = try container.decode(CLLocationDistance.self, forKey: .altitude)
        let horizontalAccuracy = try container.decode(CLLocationAccuracy.self, forKey: .horizontalAccuracy)
        let verticalAccuracy = try container.decode(CLLocationAccuracy.self, forKey: .verticalAccuracy)
        let speed = try container.decode(CLLocationSpeed.self, forKey: .speed)
        let course = try container.decode(CLLocationDirection.self, forKey: .course)
        let timestamp = try container.decode(Date.self, forKey: .timestamp)

        let location = CLLocation(coordinate: CLLocationCoordinate2DMake(latitude, longitude),
                                  altitude: altitude,
                                  horizontalAccuracy: horizontalAccuracy,
                                  verticalAccuracy: verticalAccuracy,
                                  course: course,
                                  speed: speed,
                                  timestamp: timestamp)
        self.init(location)
    }

}
