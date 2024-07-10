//
//  CommentsUIComposer.swift
//  InTheGym
//
//  Created by Findlay Wood on 10/07/2024.
//  Copyright © 2024 FindlayWood. All rights reserved.
//

import UIKit
import Combine
import ITGWorkoutKit
import ITGWorkoutKitiOS

public final class CommentsUIComposer {
    private init() {}

    private typealias FeedPresentationAdapter = LoadResourcePresentationAdapter<[WorkoutItem], FeedViewAdapter>

    public static func commentsComposedWith(
        commentsLoader: @escaping () -> AnyPublisher<[WorkoutItem], Error>
    ) -> ListViewController {
        let presentationAdapter = FeedPresentationAdapter(loader: commentsLoader)

        let feedController = makeFeedViewController(title: FeedPresenter.title)
        feedController.onRefresh = presentationAdapter.loadResource

        presentationAdapter.presenter = LoadResourcePresenter(
            resourceView: FeedViewAdapter(
                controller: feedController,
                imageLoader: { _ in Empty<Data, Error>().eraseToAnyPublisher() }),
            loadingView: WeakRefVirtualProxy(feedController),
            errorView: WeakRefVirtualProxy(feedController),
            mapper: FeedPresenter.map)

        return feedController
    }

    private static func makeFeedViewController(title: String) -> ListViewController {
        let bundle = Bundle(for: ListViewController.self)
        let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
        let feedController = storyboard.instantiateInitialViewController() as! ListViewController
        feedController.title = title
        return feedController
    }
}
