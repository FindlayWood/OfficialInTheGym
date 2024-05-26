//
//  ExerciseCacheTestHelpers.swift
//  ITGWorkoutKitTests
//
//  Created by Findlay Wood on 26/05/2024.
//

import Foundation
import ITGWorkoutKit

func uniqueItem() -> ExerciseItem {
    return ExerciseItem(id: UUID(), name: "any", bodyArea: "any")
}

func uniqueItemList() -> (models: [ExerciseItem], local: [LocalExerciseItem]) {
    let models = [uniqueItem(), uniqueItem()]
    let local = models.map { LocalExerciseItem(id: $0.id, name: $0.name, bodyArea: $0.bodyArea) }
    return (models, local)
}

extension Date {
    
    func minusExerciseCacheMaxAge() -> Date {
        return adding(days: -exerciseCacheMaxAgeInDays)
    }
    
    private var exerciseCacheMaxAgeInDays: Int {
        return 7
    }
    
    private func adding(days: Int) -> Date {
        return Calendar(identifier: .gregorian).date(byAdding: .day, value: days, to: self)!
    }
}
