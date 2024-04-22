//
//  FeedViewModel.swift
//  ITGWorkoutKitiOS
//
//  Created by Findlay Wood on 22/04/2024.
//

import Foundation
import ITGWorkoutKit

final class FeedViewModel {
    private let feedLoader: WorkoutLoader

    init(feedLoader: WorkoutLoader) {
        self.feedLoader = feedLoader
    }

    var onChange: ((FeedViewModel) -> Void)?
    var onFeedLoad: (([WorkoutItem]) -> Void)?

    private(set) var isLoading: Bool = false {
        didSet { onChange?(self) }
    }

    func loadFeed() {
        isLoading = true
        feedLoader.load { [weak self] result in
            if let feed = try? result.get() {
                self?.onFeedLoad?(feed)
            }
            self?.isLoading = false
        }
    }
}
