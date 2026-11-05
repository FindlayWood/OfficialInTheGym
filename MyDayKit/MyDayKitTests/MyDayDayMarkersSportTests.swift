//
//  MyDayDayMarkersSportTests.swift
//  MyDayKitTests
//
//  Created by Findlay Wood on 05/11/2026.
//

import XCTest
@testable import MyDayKit

final class MyDayDayMarkersSportTests: XCTestCase {

    // A day of basketball alone is a training day. Without this the date strip
    // would show it as untrained and the rate step would never open.
    func test_init_deliversExerciseMarkerForDayWithOnlySport() {
        let sut = MyDayDayMarkers(day: day(sports: [.basketballGame()]))

        XCTAssertTrue(sut.hasExercise)
        XCTAssertFalse(sut.isEmpty)
    }

    func test_init_deliversNoExerciseMarkerForDayWithEmptySports() {
        XCTAssertFalse(MyDayDayMarkers(day: day(sports: [])).hasExercise)
    }

    func test_init_deliversNoExerciseMarkerForDayWrittenBeforeSports() {
        XCTAssertFalse(MyDayDayMarkers(day: day(sports: nil)).hasExercise)
    }

    // MARK: - Helpers

    private func day(sports: [SportSessionEntry]?) -> MyDayFullDayModel {
        MyDayFullDayModel(
            id: "day", date: Date(timeIntervalSince1970: 1_800_000_000),
            exercises: [], workouts: [], sports: sports
        )
    }
}
