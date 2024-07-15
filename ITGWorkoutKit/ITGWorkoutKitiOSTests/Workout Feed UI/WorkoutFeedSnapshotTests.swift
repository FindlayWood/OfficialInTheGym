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
        let sut = makeSUT()

        sut.display(workouts())

        assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "WORKOUT_FEED_light")
        assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "WORKOUT_FEED_dark")
        assert(snapshot: sut.snapshot(for: .iPhone(style: .light, contentSize: .extraExtraExtraLarge)), named: "WORKOUT_FEED_light_extraExtraExtraLarge")
    }

    // MARK: - Helpers

    private func makeSUT() -> ListViewController {
        let controller = ListViewController()
        controller.loadViewIfNeeded()
        controller.tableView.showsVerticalScrollIndicator = false
        controller.tableView.showsHorizontalScrollIndicator = false
        return controller
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
