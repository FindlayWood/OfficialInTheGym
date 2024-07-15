//
//  WorkoutFeedUIComposer.swift
//  InTheGym
//
//  Created by Findlay Wood on 15/07/2024.
//  Copyright © 2024 FindlayWood. All rights reserved.
//

import UIKit
import Combine
import ITGWorkoutKit
import ITGWorkoutKitiOS

public final class WorkoutFeedUIComposer {
    private init() {}

    private typealias WorkoutFeedPresentationAdapter = LoadResourcePresentationAdapter<[WorkoutFeedItem], WorkoutFeedViewAdapter>

    public static func workoutsComposedWith(
        workoutsLoader: @escaping () -> AnyPublisher<[WorkoutFeedItem], Error>
    ) -> ListViewController {
        let presentationAdapter = WorkoutFeedPresentationAdapter(loader: workoutsLoader)

        let workoutFeedController = makeWorkoutFeedViewController(title: WorkoutFeedPresenter.title)
        workoutFeedController.onRefresh = presentationAdapter.loadResource

        presentationAdapter.presenter = LoadResourcePresenter(
            resourceView: WorkoutFeedViewAdapter(controller: workoutFeedController),
            loadingView: WeakRefVirtualProxy(workoutFeedController),
            errorView: WeakRefVirtualProxy(workoutFeedController),
            mapper: { WorkoutFeedPresenter.map($0) })

        return workoutFeedController
    }

    private static func makeWorkoutFeedViewController(title: String) -> ListViewController {
        let bundle = Bundle(for: ListViewController.self)
        let storyboard = UIStoryboard(name: "WorkoutFeed", bundle: bundle)
        let controller = storyboard.instantiateInitialViewController() as! ListViewController
        controller.title = title
        return controller
    }
}

final class WorkoutFeedViewAdapter: ResourceView {
    private weak var controller: ListViewController?
    
    private typealias ImageDataPresentationAdapter = LoadResourcePresentationAdapter<Data, WeakRefVirtualProxy<FeedImageCellController>>

    init(controller: ListViewController) {
        self.controller = controller
    }
    
    func display(_ viewModel: WorkoutFeedViewModel) {
        controller?.display(viewModel.workouts.map { viewModel in
            CellController(id: viewModel, WorkoutFeedCellController(model: viewModel))
        })
    }
}
