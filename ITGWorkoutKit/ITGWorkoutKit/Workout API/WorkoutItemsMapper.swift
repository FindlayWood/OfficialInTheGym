//
//  WorkoutItemsMapper.swift
//  ITGWorkoutKit
//
//  Created by Findlay Wood on 11/03/2024.
//

import Foundation

public final class WorkoutItemsMapper {
    private struct Root: Decodable {
        private let items: [RemoteWorkoutItem]
        
        private struct RemoteWorkoutItem: Decodable {
            let id: UUID
            let description: String?
            let location: String?
            let image: URL
        }
        
        var publicItems: [WorkoutItem] {
            items.map { WorkoutItem(id: $0.id, description: $0.description, location: $0.location, image: $0.image) }
        }
    }
    
    public enum Error: Swift.Error {
         case invalidData
     }
    
    private static var OK_200: Int { return 200 }
    
    public static func map(_ data: Data, from response: HTTPURLResponse) throws -> [WorkoutItem] {
        guard response.statusCode == OK_200,
              let root = try? JSONDecoder().decode(Root.self, from: data) else {
            throw Error.invalidData
        }

        return root.publicItems
    }
}
