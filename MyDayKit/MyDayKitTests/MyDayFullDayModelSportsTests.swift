//
//  MyDayFullDayModelSportsTests.swift
//  MyDayKitTests
//
//  Created by Findlay Wood on 05/11/2026.
//

import XCTest
@testable import MyDayKit

final class MyDayFullDayModelSportsTests: XCTestCase {

    func test_addingSport_appendsToDayWithNoSports() {
        let sut = emptyDay().addingSport(.basketballGame())

        XCTAssertEqual(sut.sports, [.basketballGame()])
    }

    func test_addingSport_appendsAfterExistingSessions() {
        let sut = emptyDay().addingSport(.basketballGame()).addingSport(.golfRound())

        XCTAssertEqual(sut.sports?.map(\.id), ["game", "golf"])
    }

    // Saving an edit sends the same id again. Appending would put the game on
    // the day twice and count its load twice.
    func test_addingSport_replacesSessionWithSameId() {
        let edited = SportSessionEntry(
            id: "game", sport: .basketball, sessionType: .game, performedAt: .basketballGameDate,
            duration: 5_400, playingTime: 3_000, rpe: 8, result: .loss,
            teamScore: 60, opponentScore: 64, note: nil
        )

        let sut = emptyDay().addingSport(.basketballGame()).addingSport(edited)

        XCTAssertEqual(sut.sports, [edited])
    }

    func test_removingSport_removesOnlyThatSession() {
        let sut = emptyDay().addingSport(.basketballGame()).addingSport(.golfRound()).removingSport(id: "game")

        XCTAssertEqual(sut.sports, [.golfRound()])
    }

    func test_removingSport_leavesDayUnchangedForUnknownId() {
        let sut = emptyDay().addingSport(.golfRound()).removingSport(id: "missing")

        XCTAssertEqual(sut.sports, [.golfRound()])
    }

    // MARK: - Helpers

    private func emptyDay() -> MyDayFullDayModel {
        MyDayFullDayModel(id: "day", date: .basketballGameDate, exercises: [], workouts: [])
    }
}

private extension Date {
    static let basketballGameDate = Date(timeIntervalSince1970: 1_800_000_000)
}
