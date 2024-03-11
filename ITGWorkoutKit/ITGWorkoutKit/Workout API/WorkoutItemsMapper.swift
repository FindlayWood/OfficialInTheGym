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
        let id: String
        let title: String
        
        var item: WorkoutItem {
            return WorkoutItem(id: id, title: title)
        }
    }
    
    private static var OK_200: Int { return 200 }
    
    static func map(_ data: Data, from response: HTTPURLResponse) throws -> [WorkoutItem] {
        guard response.statusCode == OK_200 else {
            throw RemoteWorkoutLoader.Error.invalidData
        }
        
        let root = try JSONDecoder().decode(Root.self, from: data)

        return root.feed
    }
}
