//
//  FeedUIComposer.swift
//  ITGWorkoutKitiOS
//
//  Created by Findlay Wood on 21/04/2024.
//

import UIKit
import Combine
import ITGWorkoutKit
import ITGWorkoutKitiOS

public final class FeedUIComposer {
    
    private init() {}
    
    private typealias FeedPresentationAdapter = LoadResourcePresentationAdapter<[WorkoutItem], FeedViewAdapter>

    public static func feedComposedWith(feedLoader: @escaping () -> AnyPublisher<[WorkoutItem], Error>, imageLoader: @escaping (URL) -> FeedImageDataLoader.Publisher) -> FeedViewController {
        let presentationAdapter = FeedPresentationAdapter(
            loader: feedLoader)
        
        let feedController = makeFeedViewController(
                    delegate: presentationAdapter,
                    title: FeedPresenter.title)
        
        presentationAdapter.presenter = LoadResourcePresenter(
            resourceView: FeedViewAdapter(controller: feedController, imageLoader: imageLoader),
            loadingView: WeakRefVirtualProxy(feedController),
            errorView: WeakRefVirtualProxy(feedController),
            mapper: FeedPresenter.map)
        
        return feedController
    }
    
    private static func makeFeedViewController(delegate: FeedViewControllerDelegate, title: String) -> FeedViewController {
        let bundle = Bundle(for: FeedViewController.self)
        let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
        let feedController = storyboard.instantiateInitialViewController() as! FeedViewController
        feedController.delegate = delegate
        feedController.title = title
        return feedController
    }
}
