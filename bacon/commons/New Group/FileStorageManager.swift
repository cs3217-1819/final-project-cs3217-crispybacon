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
    /// - Returns: A `URL` object, or `nil` if the path cannot be generated.
    private func generatePath(directory: FileManager.SearchPathDirectory,
                              domainMask: FileManager.SearchPathDomainMask,
                              fileName: String) -> URL? {
        // Get the URL of the directory
        let urls = FileManager.default.urls(for: directory, in: domainMask)

        // Get the URL for a file in the directory
        guard let documentDirectory = urls.first else {
            return nil
        }
        let fileUrl = documentDirectory.appendingPathComponent(fileName)

        return fileUrl
    }

    /// Writes data to the file system encoded as JSON.
    /// - Returns: `true` if the operation is successful, and `false` otherwise.
    func writeAsJson<T: Encodable>(data: T,
                                   to directory: FileManager.SearchPathDirectory,
                                   in domainMask: FileManager.SearchPathDomainMask,
                                   as fileName: String) -> Bool {
        guard let fileUrl = generatePath(directory: directory,
                                         domainMask: domainMask,
                                         fileName: fileName) else {
                                            return false
        }

        // Encode to JSON
        let jsonEncoder = JSONEncoder()
        guard let encodedData = try? jsonEncoder.encode(data) else {
            return false
        }

        // Write
        do {
            try encodedData.write(to: fileUrl)
        } catch {
            return false
        }

        return true
    }

    /// Reads JSON data from the file system.
    /// - Returns: The decoded data if the operation is successful, and `nil` otherwise.
    func readFromJson<T: Decodable>(_ type: T.Type,
                                    from directory: FileManager.SearchPathDirectory,
                                    in domainMask: FileManager.SearchPathDomainMask,
                                    file fileName: String) -> T? {
        guard let fileUrl = generatePath(directory: directory,
                                         domainMask: domainMask,
                                         fileName: fileName) else {
                                            return nil
        }

        let encodedData: Data

        // Read
        do {
            encodedData = try Data(contentsOf: fileUrl)
        } catch {
            return nil
        }

        // Decode from JSON
        let jsonDecoder = JSONDecoder()
        guard let decodedData = try? jsonDecoder.decode(type, from: encodedData) else {
            return nil
        }

        return decodedData
    }
}
