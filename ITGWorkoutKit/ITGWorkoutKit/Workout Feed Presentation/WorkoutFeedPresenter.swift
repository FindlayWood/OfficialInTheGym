//
//  WorkoutFeedPresenter.swift
//  ITGWorkoutKit
//
//  Created by Findlay Wood on 15/07/2024.
//

import Foundation

public struct WorkoutFeedViewModel {
    public let workouts: [WorkoutFeedItemViewModel]
}

public struct WorkoutFeedItemViewModel: Hashable {
    public let id: UUID
    public let title: String
    public let exerciseCount: String

    public init(id: UUID, title: String, exerciseCount: String) {
        self.id = id
        self.title = title
        self.exerciseCount = exerciseCount
    }
}

public final class WorkoutFeedPresenter {
    public static var title: String {
        NSLocalizedString("WORKOUT_FEED_VIEW_TITLE",
            tableName: "WorkoutFeed",
            bundle: Bundle(for: Self.self),
            comment: "Title for the workout feed view")
    }
    
    public static func map(
        _ workouts: [WorkoutFeedItem],
        currentDate: Date = Date(),
        calendar: Calendar = .current,
        locale: Locale = .current
    ) -> WorkoutFeedViewModel {
        let formatter = RelativeDateTimeFormatter()
        formatter.calendar = calendar
        formatter.locale = locale

        return WorkoutFeedViewModel(workouts: workouts.map { workout in
            WorkoutFeedItemViewModel(
                id: workout.id,
                title: workout.title,
                exerciseCount: String(workout.exerciseCount))
        })
    }
}
