//
//  FeedCache.swift
//  ITGWorkoutKit
//
//  Created by Findlay Wood on 02/06/2024.
//

import Foundation

public protocol FeedCache {
    typealias Result = Swift.Result<Void, Error>

    func save(_ feed: [WorkoutItem], completion: @escaping (Result) -> Void)
}
