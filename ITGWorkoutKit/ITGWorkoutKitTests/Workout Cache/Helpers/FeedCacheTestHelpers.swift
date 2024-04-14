//
//  FeedCacheTestHelpers.swift
//  ITGWorkoutKitTests
//
//  Created by Findlay Wood on 14/04/2024.
//

import Foundation
import ITGWorkoutKit

func uniqueImage() -> WorkoutItem {
    return WorkoutItem(id: UUID(), description: "any", location: "any", image: anyURL())
}

func uniqueImageFeed() -> (models: [WorkoutItem], local: [LocalWorkoutItem]) {
    let models = [uniqueImage(), uniqueImage()]
    let local = models.map { LocalWorkoutItem(id: $0.id, description: $0.description, location: $0.location, image: $0.image) }
    return (models, local)
}

extension Date {
    func adding(days: Int) -> Date {
        return Calendar(identifier: .gregorian).date(byAdding: .day, value: days, to: self)!
    }

    func adding(seconds: TimeInterval) -> Date {
        return self + seconds
    }
}
