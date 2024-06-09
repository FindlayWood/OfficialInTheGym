//
//  FeedLoaderPresentationAdapter.swift
//  ITGWorkoutKitiOS
//
//  Created by Findlay Wood on 28/04/2024.
//

import ITGWorkoutKit
import ITGWorkoutKitiOS

final class FeedLoaderPresentationAdapter: FeedViewControllerDelegate {
    private let feedLoader: ITGWorkoutKit.WorkoutLoader
    var presenter: FeedPresenter?

    init(feedLoader: ITGWorkoutKit.WorkoutLoader) {
        self.feedLoader = feedLoader
    }

    func didRequestFeedRefresh() {
        presenter?.didStartLoadingFeed()

        feedLoader.load { [weak self] result in
            switch result {
            case let .success(feed):
                self?.presenter?.didFinishLoadingFeed(with: feed)

            case let .failure(error):
                self?.presenter?.didFinishLoadingFeed(with: error)
            }
        }
    }
}
