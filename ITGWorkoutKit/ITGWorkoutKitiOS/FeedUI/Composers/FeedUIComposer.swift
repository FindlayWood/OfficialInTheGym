//
//  FeedUIComposer.swift
//  ITGWorkoutKitiOS
//
//  Created by Findlay Wood on 21/04/2024.
//

import Foundation
import ITGWorkoutKit

public final class FeedUIComposer {
    private init() {}

    public static func feedComposedWith(feedLoader: WorkoutLoader, imageLoader: FeedImageDataLoader) -> FeedViewController {
        let feedViewModel = FeedViewModel(feedLoader: feedLoader)
        let refreshController = FeedRefreshViewController(viewModel: feedViewModel)
        let feedController = FeedViewController(refreshController: refreshController)
        feedViewModel.onFeedLoad = adaptFeedToCellControllers(forwardingTo: feedController, loader: imageLoader)
        return feedController
    }
    
    private static func adaptFeedToCellControllers(forwardingTo controller: FeedViewController, loader: FeedImageDataLoader) -> ([WorkoutItem]) -> Void {
        return { [weak controller] feed in
            controller?.tableModel = feed.map { model in
                FeedImageCellController(viewModel: FeedImageViewModel(model: model, imageLoader: loader))
            }
        }
    }

}
