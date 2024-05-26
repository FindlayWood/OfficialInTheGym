//
//  ExerciseItemsMapper.swift
//  ITGWorkoutKit
//
//  Created by Findlay Wood on 25/05/2024.
//

import Foundation

final class ExerciseItemsMapper {
    private struct Root: Decodable {
        private let exercises: [RemoteExerciseItem]
        
        private struct RemoteExerciseItem: Decodable {
            let id: UUID
            let name: String
            let bodyArea: String
        }
        
        var items: [ExerciseItem] {
            exercises.map { ExerciseItem(id: $0.id, name: $0.name, bodyArea: $0.bodyArea) }
        }
        
    }
    
    private static var OK_200: Int { return 200 }
    
    static func map(_ data: Data, from response: HTTPURLResponse) throws -> [ExerciseItem] {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        guard response.statusCode == OK_200,
              let root = try? decoder.decode(Root.self, from: data) else {
            throw RemoteExerciseLoader.Error.invalidData
        }

        return root.items
    }
}
