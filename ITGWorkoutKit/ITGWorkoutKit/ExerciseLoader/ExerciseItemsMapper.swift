//
//  ExerciseItemsMapper.swift
//  ITGWorkoutKit
//
//  Created by Findlay Wood on 25/05/2024.
//

import Foundation

public final class ExerciseItemsMapper {
    private struct Root: Decodable {
        private let items: [RemoteExerciseItem]
        
        private struct RemoteExerciseItem: Decodable {
            let id: UUID
            let name: String
            let bodyArea: String
        }
        
        var publicItems: [ExerciseItem] {
            items.map { ExerciseItem(id: $0.id, name: $0.name, bodyArea: $0.bodyArea) }
        }
        
    }
    
    private static func isOK(_ response: HTTPURLResponse) -> Bool {
        (200...299).contains(response.statusCode)
    }
    
    public static func map(_ data: Data, from response: HTTPURLResponse) throws -> [ExerciseItem] {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        guard isOK(response),
              let root = try? decoder.decode(Root.self, from: data) else {
            throw RemoteExerciseLoader.Error.invalidData
        }

        return root.publicItems
    }
}
