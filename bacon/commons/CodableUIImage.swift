//
//  CodableUIImage.swift
//  bacon
//
//  Created by Fabian Terh on 2/4/19.
//  Copyright © 2019 nus.CS3217. All rights reserved.
//

import Foundation
import UIKit

/// Codable wrapper around CLLocation.
struct CodableUIImage: Codable {

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
