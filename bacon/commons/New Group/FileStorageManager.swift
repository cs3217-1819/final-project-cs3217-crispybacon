//
//  FileStorageManager.swift
//  bacon
//
//  Created by Fabian Terh on 11/4/19.
//  Copyright © 2019 nus.CS3217. All rights reserved.
//

import Foundation

/// Handles data storage and retrieval to and from the file system.
class FileStorageManager {

    /// Generates and returns the path of a file in a directory as a URL.
    /// - Throws: `InvalidArgumentError` if the path cannot be generated.
    private func generatePath(directory: FileManager.SearchPathDirectory,
                              domainMask: FileManager.SearchPathDomainMask,
                              fileName: String) throws -> URL {
        // Get the URL of the directory
        let urls = FileManager.default.urls(for: directory, in: domainMask)

        // Get the URL for a file in the directory
        guard let documentDirectory = urls.first else {
            throw InvalidArgumentError(message: "Invalid document directory")
        }
        let fileUrl = documentDirectory.appendingPathComponent(fileName)

        return fileUrl
    }

    /// Writes data to the file system encoded as JSON.
    /// - Throws: Any errors encountered will be rethrown.
    func writeAsJson<T: Encodable>(data: T,
                                   as fileName: String,
                                   to directory: FileManager.SearchPathDirectory = .documentDirectory,
                                   in domainMask: FileManager.SearchPathDomainMask = .userDomainMask) throws {
        let fileUrl = try generatePath(directory: directory,
                                       domainMask: domainMask,
                                       fileName: fileName)

        let jsonEncoder = JSONEncoder()
        let encodedData = try jsonEncoder.encode(data)

        try encodedData.write(to: fileUrl)
    }

    /// Reads JSON data from the file system.
    /// - Throws: Any errors encountered will be rethrown.
    func readFromJson<T: Decodable>(_ type: T.Type,
                                    file fileName: String,
                                    from directory: FileManager.SearchPathDirectory = .documentDirectory	,
                                    in domainMask: FileManager.SearchPathDomainMask = .userDomainMask) throws -> T {
        let fileUrl = try generatePath(directory: directory,
                                       domainMask: domainMask,
                                       fileName: fileName)

        let encodedData = try Data(contentsOf: fileUrl)

        // Decode from JSON
        let jsonDecoder = JSONDecoder()
        let decodedData = try jsonDecoder.decode(type, from: encodedData)

        return decodedData
    }
}
