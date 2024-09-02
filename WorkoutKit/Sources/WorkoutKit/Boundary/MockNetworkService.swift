//
//  File.swift
//  
//
//  Created by Findlay-Personal on 02/05/2023.
//

import Foundation

class Mock: NetworkService {
    
    static let shared = Mock()
    
    private init() {}
    
    func write(data: Codable, at path: String) async throws {
        
    }
    
    func read<T>(at path: String) async throws -> T where T : Codable {
        return T.self as! T
    }
    func readAll<T>(at path: String) async throws -> [T] where T : Decodable, T : Encodable {
        return [T.self] as! [T]
    }
}
