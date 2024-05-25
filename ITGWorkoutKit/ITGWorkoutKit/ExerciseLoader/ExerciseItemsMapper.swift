//
//  ExerciseItemsMapper.swift
//  ITGWorkoutKit
//
//  Created by Findlay Wood on 25/05/2024.
//

import Foundation

final class ExerciseItemsMapper {
    private struct Root: Decodable {
        let exercises: [RemoteExerciseItem]
    }
    
    private static var OK_200: Int { return 200 }
    
    static func map(_ data: Data, from response: HTTPURLResponse) throws -> [RemoteExerciseItem] {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        guard response.statusCode == OK_200,
              let root = try? decoder.decode(Root.self, from: data) else {
            throw RemoteExerciseLoader.Error.invalidData
        }

        return root.exercises
    }
}
