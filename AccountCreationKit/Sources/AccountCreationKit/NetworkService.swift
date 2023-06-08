//
//  File.swift
//  
//
//  Created by Findlay-Personal on 08/04/2023.
//

import Foundation

public protocol NetworkService {
    func signout() async throws
    func upload(data: Codable, at path: String) async throws
    func dataUpload(data: Data, at path: String) async throws
    func checkExistence(at path: String) async throws -> Bool
}

class MockNetworkService: NetworkService {
    
    static let shared = MockNetworkService()
    
    private init() {}
    
    func signout() async throws {
        
    }
    func upload(data: Codable, at path: String) async throws {
        
    }
    func dataUpload(data: Data, at path: String) async throws {
        
    }
    func checkExistence(at path: String) async throws -> Bool {
        return false
    }
}
