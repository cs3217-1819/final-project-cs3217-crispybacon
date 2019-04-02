//
//  CodableUIImage.swift
//  bacon
//
//  Created by Fabian Terh on 2/4/19.
//  Copyright © 2019 nus.CS3217. All rights reserved.
//

import Foundation
import UIKit

// MARK: UIImage: Equatable
// Although UIImage conforms to Equatable already, it is using NSObject's isEqual() method.
// According to Apple's UIImage documentation (https://developer.apple.com/documentation/uikit/uiimage),
// this is "the only reliable way to determine whether two images contain the same image data".
// However, testing shows that this does not always work as expected.
//
// This extension overrides the default isEqual() method to compare using only image data.
extension UIImage: Equatable {

    static func == (lhs: UIImage, rhs: UIImage) -> Bool {
        return lhs.pngData()?.base64EncodedString() == rhs.pngData()?.base64EncodedString()
    }

    // Override the != comparison too to use the negation of ==.
    static func != (lhs: UIImage, rhs: UIImage) -> Bool {
        return !(lhs == rhs)
    }

    // Override NSObject's isEqual() method to use == logic as defined above.
    override open func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? UIImage else {
            return false
        }

        return self == other
    }

}

// MARK: CodableUIImage
/// Codable and Equatable wrapper around CLLocation.
struct CodableUIImage: Codable, Equatable {

    let image: UIImage

    private enum CodingKeys: String, CodingKey {
        case encodedImageData
    }

    init(_ image: UIImage) {
        self.image = image
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        let imageData = image.pngData() // Using pngData() instead of jpegData() allows lossless conversion,
            // which allows CodableUIImage to be testable
        let encodedImageData = imageData?.base64EncodedString()

        try container.encode(encodedImageData, forKey: .encodedImageData)
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let encodedImageData = try container.decode(String.self, forKey: .encodedImageData)
        guard let imageData = Data(base64Encoded: encodedImageData) else {
            // Maybe we could throw and/or log if this happens
            fatalError("This should never happen")
        }

        guard let reconstructedImage = UIImage(data: imageData) else {
            // Maybe we could throw and/or log if this happens
            fatalError("This should never happen")
        }

        image = reconstructedImage
    }

}
