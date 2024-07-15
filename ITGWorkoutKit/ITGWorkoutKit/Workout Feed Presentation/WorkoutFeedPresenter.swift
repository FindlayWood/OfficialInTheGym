//
//  WorkoutFeedPresenter.swift
//  ITGWorkoutKit
//
//  Created by Findlay Wood on 15/07/2024.
//

import Foundation

public final class WorkoutFeedPresenter {
    public static var title: String {
        NSLocalizedString("WORKOUT_FEED_VIEW_TITLE",
            tableName: "WorkoutFeed",
            bundle: Bundle(for: Self.self),
            comment: "Title for the workout feed view")
    }
    
//    public static func map(
//        _ comments: [ImageComment],
//        currentDate: Date = Date(),
//        calendar: Calendar = .current,
//        locale: Locale = .current
//    ) -> ImageCommentsViewModel {
//        let formatter = RelativeDateTimeFormatter()
//        formatter.calendar = calendar
//        formatter.locale = locale
//
//        return ImageCommentsViewModel(comments: comments.map { comment in
//            ImageCommentViewModel(
//                message: comment.message,
//                date: formatter.localizedString(for: comment.createdAt, relativeTo: currentDate),
//                username: comment.username)
//        })
//    }
}
