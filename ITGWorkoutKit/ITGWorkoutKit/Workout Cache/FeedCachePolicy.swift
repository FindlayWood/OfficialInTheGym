//
//  FeedCachePolicy.swift
//  ITGWorkoutKit
//
//  Created by Findlay Wood on 14/04/2024.
//

import Foundation

internal final class FeedCachePolicy {
    
    /// there never needs to be an instance of this policy
    /// there is no identity - it is just a policy
    private init() {}
    
    private static let calendar = Calendar(identifier: .gregorian)
    
    private static var maxCacheAgeInDays: Int {
        return 7
    }
    
    internal static func validate(_ timestamp: Date, against date: Date) -> Bool {
        guard let maxCacheAge = calendar.date(byAdding: .day, value: maxCacheAgeInDays, to: timestamp) else {
            return false
        }
        return date < maxCacheAge
    }
}
