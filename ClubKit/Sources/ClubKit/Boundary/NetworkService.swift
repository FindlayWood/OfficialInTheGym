//
//  File.swift
//  
//
//  Created by Findlay-Personal on 10/05/2023.
//

import Foundation

public protocol NetworkService {
    func write(dataPoints: [String: Codable]) async throws
    func read<T: Codable>(at path: String) async throws -> T
    func readAll<T:Codable>(at path: String) async throws -> [T]
}
