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
    func read<T:Codable>(at path: String) async throws -> T
    func callFunction(named: String, with data: Any) async throws
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
    func read<T:Codable>(at path: String) async throws -> T {
        return T.self as! T
    }
    func callFunction(named: String, with data: Any) async throws {
        
    }
}
