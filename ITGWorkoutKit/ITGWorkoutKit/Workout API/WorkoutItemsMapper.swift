//
//  WorkoutItemsMapper.swift
//  ITGWorkoutKit
//
//  Created by Findlay Wood on 11/03/2024.
//

import Foundation

internal struct RemoteWorkoutItem: Decodable {
    internal let id: UUID
    internal let description: String?
    internal let location: String?
    internal let image: URL
}

internal final class WorkoutItemsMapper {
    private struct Root: Decodable {
        let items: [RemoteWorkoutItem]
    }
    
    private static var OK_200: Int { return 200 }
    
    static func map(_ data: Data, from response: HTTPURLResponse) throws -> [RemoteWorkoutItem] {
        guard response.statusCode == OK_200,
              let root = try? JSONDecoder().decode(Root.self, from: data) else {
            throw RemoteWorkoutLoader.Error.invalidData
        }

        return root.items
    }
}
