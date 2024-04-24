//
//  FeedPresenter.swift
//  ITGWorkoutKitiOS
//
//  Created by Findlay Wood on 24/04/2024.
//

import ITGWorkoutKit

protocol FeedLoadingView {
    func display(isLoading: Bool)
}

protocol FeedView {
    func display(feed: [WorkoutItem])
}

final class FeedPresenter {
    typealias Observer<T> = (T) -> Void

    private let feedLoader: WorkoutLoader

    init(feedLoader: WorkoutLoader) {
        self.feedLoader = feedLoader
    }

    var feedView: FeedView?
    var loadingView: FeedLoadingView?

    func loadFeed() {
        loadingView?.display(isLoading: true)
        feedLoader.load { [weak self] result in
            if let feed = try? result.get() {
                self?.feedView?.display(feed: feed)
            }
            self?.loadingView?.display(isLoading: false)
        }
    }
}
