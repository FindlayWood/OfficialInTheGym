//
//  WorkoutFeedPresenterTests.swift
//  ITGWorkoutKitTests
//
//  Created by Findlay Wood on 14/07/2024.
//

import XCTest
import ITGWorkoutKit

final class WorkoutFeedPresenterTests: XCTestCase {

    func test_title_isLocalized() {
        XCTAssertEqual(WorkoutFeedPresenter.title, localized("WORKOUT_FEED_VIEW_TITLE"))
    }
    
    func test_map_createsViewModels() {
        let now = Date()
        let calendar = Calendar(identifier: .gregorian)
        let locale = Locale(identifier: "en_US_POSIX")

        let workouts = [
            WorkoutFeedItem(
                id: UUID(),
                addedToListDate: now.adding(days: -1, calendar: calendar),
                createdDate: now.adding(days: -1, calendar: calendar),
                creatorID: UUID().uuidString,
                exerciseCount: 4,
                savedWorkoutID: UUID(),
                title: "a title"),
            WorkoutFeedItem(
                id: UUID(),
                addedToListDate: now.adding(days: -1, calendar: calendar),
                createdDate: now.adding(days: -1, calendar: calendar),
                creatorID: UUID().uuidString,
                exerciseCount: 18,
                savedWorkoutID: UUID(),
                title: "another title"),
        ]

        let viewModel = WorkoutFeedPresenter.map(
            workouts,
            currentDate: now,
            calendar: calendar,
            locale: locale
        )

        XCTAssertEqual(viewModel.workouts, [
            WorkoutFeedItemViewModel(
                title: "a title",
                exerciseCount: "4"
            ),
            WorkoutFeedItemViewModel(
                title: "another title",
                exerciseCount: "18"
            )
        ])
    }
    
    // MARK: - Helpers

    private func localized(_ key: String, file: StaticString = #filePath, line: UInt = #line) -> String {
        let table = "WorkoutFeed"
        let bundle = Bundle(for: WorkoutFeedPresenter.self)
        let value = bundle.localizedString(forKey: key, value: nil, table: table)
        if value == key {
            XCTFail("Missing localized string for key: \(key) in table: \(table)", file: file, line: line)
        }
        return value
    }

}
