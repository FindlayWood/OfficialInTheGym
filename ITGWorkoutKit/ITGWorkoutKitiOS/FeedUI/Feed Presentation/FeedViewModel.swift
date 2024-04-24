//
//  FeedViewModel.swift
//  ITGWorkoutKitiOS
//
//  Created by Findlay Wood on 22/04/2024.
//

import ITGWorkoutKit

final class FeedViewModel {
    typealias Observer<T> = (T) -> Void
    
    private let feedLoader: WorkoutLoader

    init(feedLoader: WorkoutLoader) {
        self.feedLoader = feedLoader
    }

    var onLoadingStateChange: Observer<Bool>?
    var onFeedLoad: Observer<[WorkoutItem]>?

    func loadFeed() {
        onLoadingStateChange?(true)
        feedLoader.load { [weak self] result in
            if let feed = try? result.get() {
                self?.onFeedLoad?(feed)
            }
            self?.onLoadingStateChange?(false)
        }
    }
}
