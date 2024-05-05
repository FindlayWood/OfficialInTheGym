//
//  WorkoutItemsMapper2.swift
//  ITGWorkoutKit
//
//  Created by Findlay Wood on 05/05/2024.
//

import Foundation

internal final class WorkoutItemsMapper2 {
    private struct Root: Decodable {
        let workouts: [RemoteWorkoutItem2]
    }
    
    private static var OK_200: Int { return 200 }
    
    static func map(_ data: Data, from response: HTTPURLResponse) throws -> [RemoteWorkoutItem2] {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        guard response.statusCode == OK_200,
              let root = try? decoder.decode(Root.self, from: data) else {
            throw FirestoreWorkoutLoader.Error.invalidData
        }

        return root.workouts
    }
}
