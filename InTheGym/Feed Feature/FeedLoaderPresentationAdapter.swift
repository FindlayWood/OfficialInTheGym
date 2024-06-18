//
//  FeedLoaderPresentationAdapter.swift
//  ITGWorkoutKitiOS
//
//  Created by Findlay Wood on 28/04/2024.
//

import Combine
import ITGWorkoutKit
import ITGWorkoutKitiOS

final class FeedLoaderPresentationAdapter: FeedViewControllerDelegate {
    private let feedLoader: () -> AnyPublisher<[WorkoutItem], Error>
    private var cancellable: Cancellable?
    var presenter: LoadResourcePresenter<[WorkoutItem], FeedViewAdapter>?

    init(feedLoader: @escaping () -> AnyPublisher<[WorkoutItem], Error>) {
        self.feedLoader = feedLoader
    }

    func didRequestFeedRefresh() {
        presenter?.didStartLoading()

        cancellable = feedLoader()
            .dispatchOnMainQueue()
            .sink(
                receiveCompletion: { [weak self] completion in
                    switch completion {
                    case .finished: break
                        
                    case let .failure(error):
                        self?.presenter?.didFinishLoading(with: error)
                    }
                }, receiveValue: { [weak self] feed in
                    self?.presenter?.didFinishLoading(with: feed)
                })
    }
}
