//
//  WorkoutItemsMapper.swift
//  ITGWorkoutKit
//
//  Created by Findlay Wood on 11/03/2024.
//

import Foundation

internal final class WorkoutItemsMapper {
    private struct Root: Decodable {
        let items: [Item]
        
        var feed: [WorkoutItem] {
            return items.map { $0.item }
        }
    }
    
    private struct Item: Decodable {
        let id: UUID
        let description: String?
        let location: String?
        let image: URL
        
        var item: WorkoutItem {
            return WorkoutItem(id: id, description: description, location: location, image: image)
        }
    }
    
    private static var OK_200: Int { return 200 }
    
    static func map(_ data: Data, from response: HTTPURLResponse) -> RemoteWorkoutLoader.Result {
        guard response.statusCode == OK_200,
              let root = try? JSONDecoder().decode(Root.self, from: data) else {
            return .failure(RemoteWorkoutLoader.Error.invalidData)
        }

        return .success(root.feed)
    }
}
