//
//  WorkoutFeedSnapshotTests.swift
//  ITGWorkoutKitiOSTests
//
//  Created by Findlay Wood on 15/07/2024.
//

import XCTest
import ITGWorkoutKitiOS
@testable import ITGWorkoutKit

final class WorkoutFeedSnapshotTests: XCTestCase {

    func test_listWithWorkouts() {
        let (sut, nav) = makeSUT()

        sut.display(workouts())

        record(snapshot: nav.snapshot(for: .iPhone(style: .light)), named: "WORKOUT_FEED_light")
        record(snapshot: nav.snapshot(for: .iPhone(style: .dark)), named: "WORKOUT_FEED_dark")
        record(snapshot: nav.snapshot(for: .iPhone(style: .light, contentSize: .extraExtraExtraLarge)), named: "WORKOUT_FEED_light_extraExtraExtraLarge")
    }
    
    func test_emptyList() {
        let (sut, nav) = makeSUT()
        
        sut.display(emptyList())
        
        record(snapshot: nav.snapshot(for: .iPhone(style: .light)), named: "EMPTY_WORKOUT_FEED_WITH_NAV_BAR_light")
        record(snapshot: nav.snapshot(for: .iPhone(style: .dark)), named: "EMPTY_WORKOUT_FEED_WITH_NAV_BAR_dark")
    }
    
    func test_listWithErrorMessage() {
        let (sut, nav) = makeSUT()
        
        sut.display(.error(message: "This is a\nmulti-line\nerror message"))
        
        record(snapshot: nav.snapshot(for: .iPhone(style: .light)), named: "WORKOUT_FEED_WITH_NAV_BAR_WITH_ERROR_MESSAGE_light")
        record(snapshot: nav.snapshot(for: .iPhone(style: .dark)), named: "WORKOUT_FEED_WITH_NAV_BAR_WITH_ERROR_MESSAGE_dark")
        record(snapshot: nav.snapshot(for: .iPhone(style: .light, contentSize: .extraExtraExtraLarge)), named: "WORKOUT_FEED_WITH_NAV_BAR_WITH_ERROR_MESSAGE_light_extraExtraExtraLarge")
    }
    
    func test_initialLoadinglist() {
        let (sut, nav) = makeSUT()
        
        sut.display(.init(isLoading: true))
        
        record(snapshot: nav.snapshot(for: .iPhone(style: .light)), named: "WORKOUT_FEED_WITH_NAV_BAR_INITIAL_LOAD_light")
        record(snapshot: nav.snapshot(for: .iPhone(style: .dark)), named: "WORKOUT_FEED_WITH_NAV_BAR_INITIAL_LOAD_dark")
        record(snapshot: nav.snapshot(for: .iPhone(style: .light, contentSize: .extraExtraExtraLarge)), named: "WORKOUT_FEED_WITH_NAV_BAR_INITIAL_LOAD_light_extraExtraExtraLarge")
    }

    // MARK: - Helpers

//    private func makeSUT() -> LoadingListViewController {
//        let controller = LoadingListViewController()
//        controller.loadViewIfNeeded()
//        controller.tableView.showsVerticalScrollIndicator = false
//        controller.tableView.showsHorizontalScrollIndicator = false
//        controller.tableView.separatorStyle = .none
//        controller.tableView.register(WorkoutFeedCell.self, forCellReuseIdentifier: String(describing: WorkoutFeedCell.self))
//        return controller
//    }
    
    private func makeSUT() -> (LoadingListViewController, UINavigationController) {
        let controller = LoadingListViewController()
        controller.loadViewIfNeeded()
        controller.tableView.separatorStyle = .none
        controller.tableView.showsVerticalScrollIndicator = false
        controller.tableView.showsHorizontalScrollIndicator = false
        controller.title = "Workouts"
        controller.tableView.register(WorkoutFeedCell.self, forCellReuseIdentifier: String(describing: WorkoutFeedCell.self))
        let nav = UINavigationController(rootViewController: controller)
        nav.navigationBar.prefersLargeTitles = true
        return (controller, nav)
    }
    
    private func emptyList() -> [CellController] {
        return []
    }

    private func workouts() -> [CellController] {
        workoutControllers().map { CellController(id: UUID(), $0) }
    }

    private func workoutControllers() -> [WorkoutFeedCellController] {
        return [
            WorkoutFeedCellController(
                model: WorkoutFeedItemViewModel(
                    title: "workout title",
                    exerciseCount: "12"
                )
            ),
            WorkoutFeedCellController(
                model: WorkoutFeedItemViewModel(
                    title: "a different length title that should be more than 1 line",
                    exerciseCount: "100"
                )
            ),
            WorkoutFeedCellController(
                model: WorkoutFeedItemViewModel(
                    title: "t",
                    exerciseCount: "0"
                )
            ),
        ]
    }

}
