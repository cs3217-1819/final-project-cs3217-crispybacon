//
//  CodableUIImageTests.swift
//  baconTests
//
//  Created by Fabian Terh on 2/4/19.
//  Copyright © 2019 nus.CS3217. All rights reserved.
//

import XCTest
@testable import bacon

class CodableUIImageTests: XCTestCase {
    // swiftlint:disable force_try

    func test_encode_decode_jpg() {
        let testImage = TestUtils.redHeartJpg

        let encoder = JSONEncoder()
        let encodedImageData = try! encoder.encode(CodableUIImage(testImage))

        let decoder = JSONDecoder()
        let decodedImage = try! decoder.decode(CodableUIImage.self, from: encodedImageData)

        let reconstructedImage = decodedImage.image
        // testImage.isEqual(reconstructedImage) does not work (returns false)
        // We can't use == either (see: https://developer.apple.com/documentation/uikit/uiimage)
        XCTAssertEqual(testImage.pngData()?.base64EncodedString(), reconstructedImage.pngData()?.base64EncodedString())
    }

    func test_encode_decode_png() {
        let testImage = TestUtils.redHeartPng

        let encoder = JSONEncoder()
        let encodedImageData = try! encoder.encode(CodableUIImage(testImage))

        let decoder = JSONDecoder()
        let decodedImage = try! decoder.decode(CodableUIImage.self, from: encodedImageData)

        let reconstructedImage = decodedImage.image
        // testImage.isEqual(reconstructedImage) does not work (returns false)
        // We can't use == either (see: https://developer.apple.com/documentation/uikit/uiimage)
        XCTAssertEqual(testImage.pngData()?.base64EncodedString(), reconstructedImage.pngData()?.base64EncodedString())
    }

    // swiftlint:enable force_try
}
