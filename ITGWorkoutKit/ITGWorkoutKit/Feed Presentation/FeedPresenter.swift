//
//  FeedPresenter.swift
//  ITGWorkoutKit
//
//  Created by Findlay Wood on 30/04/2024.
//

import Foundation

public final class FeedPresenter {
    
    public static var title: String {
        return NSLocalizedString("FEED_VIEW_TITLE",
            tableName: "Feed",
            bundle: Bundle(for: FeedPresenter.self),
            comment: "Title for the feed view")
    }
    
    public static func map(_ feed: [WorkoutItem]) -> FeedViewModel {
        FeedViewModel(feed: feed)
    }
}
