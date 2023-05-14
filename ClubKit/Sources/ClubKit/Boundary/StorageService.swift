//
//  File.swift
//  
//
//  Created by Findlay-Personal on 11/05/2023.
//

import Foundation

protocol StorageService {
    /// download data async
    /// - Parameters:
    ///   - path: The path to the location of data.
    ///   - maxSize: The maximum size in bytes to download. If the download exceeds this size, the task will be cancelled and an error will be returned.
    /// - Returns: Data
    func getData(at path: String, maxSize: Int64) async throws -> Data
}
