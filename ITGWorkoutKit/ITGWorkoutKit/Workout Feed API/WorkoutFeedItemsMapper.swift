//
//  WorkoutFeedItemsMapper.swift
//  ITGWorkoutKit
//
//  Created by Findlay Wood on 13/07/2024.
//

import Foundation

public final class WorkoutFeedItemsMapper {
    private struct Root: Decodable {
        private let items: [Item]

        private struct Item: Decodable {
            let id: UUID
            let addedToListDate: Date
            let createdDate: Date
            let creatorID: String
            let exerciseCount: Int
            let savedWorkoutID: UUID
            let title: String
        }

        private struct Author: Decodable {
            let username: String
        }

        var comments: [WorkoutFeedItem] {
            items.map { WorkoutFeedItem(id: $0.id, addedToListDate: $0.addedToListDate, createdDate: $0.createdDate, creatorID: $0.creatorID, exerciseCount: $0.exerciseCount, savedWorkoutID: $0.savedWorkoutID, title: $0.title) }
        }
    }
    
    public enum Error: Swift.Error {
         case invalidData
     }
    
    public static func map(_ data: Data) throws -> [WorkoutFeedItem] {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        guard let root = try? decoder.decode(Root.self, from: data) else {
            throw Error.invalidData
        }
        
        return root.comments
    }
}
