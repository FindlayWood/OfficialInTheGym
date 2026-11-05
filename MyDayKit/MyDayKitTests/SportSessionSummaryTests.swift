//
//  SportSessionSummaryTests.swift
//  MyDayKitTests
//
//  Created by Findlay Wood on 05/11/2026.
//

import XCTest
@testable import MyDayKit

final class SportSessionSummaryTests: XCTestCase {

    func test_init_deliversGameWithResultAndScore() {
        let sut = SportSessionSummary(.basketballGame())

        XCTAssertEqual(sut.label, "SPORT · GAME")
        XCTAssertEqual(sut.title, "Basketball")
        XCTAssertEqual(sut.subtitle, "40m played · RPE 7")
        XCTAssertEqual(sut.outcome, "W 68–61")
    }

    // The card shows the time stats count. Showing the 90-minute game while
    // load uses the 40 minutes played would make the two disagree.
    func test_init_deliversPlayingTimeNotDurationForGame() {
        XCTAssertEqual(SportSessionSummary(.basketballGame()).subtitle, "40m played · RPE 7")
    }

    func test_init_deliversDurationForTraining() {
        let sut = SportSessionSummary(.golfRound())

        XCTAssertEqual(sut.label, "SPORT · TRAINING")
        XCTAssertEqual(sut.subtitle, "4h · RPE 3")
        XCTAssertNil(sut.outcome)
    }

    func test_init_leavesOutRPEWhenNotGiven() {
        XCTAssertEqual(SportSessionSummary(game(rpe: nil)).subtitle, "40m played")
    }

    func test_init_deliversResultAloneWithoutScore() {
        XCTAssertEqual(SportSessionSummary(game(result: .draw, teamScore: nil, opponentScore: nil)).outcome, "Draw")
    }

    func test_init_deliversScoreAloneWithoutResult() {
        XCTAssertEqual(SportSessionSummary(game(result: nil)).outcome, "68–61")
    }

    // Half a score is not a score — "68–" would read as a typo.
    func test_init_deliversNoOutcomeForGameWithHalfAScoreAndNoResult() {
        XCTAssertNil(SportSessionSummary(game(result: nil, opponentScore: nil)).outcome)
    }

    func test_formatted_deliversHoursAndMinutes() {
        XCTAssertEqual(SportSessionSummary.formatted(seconds: 5_400), "1h 30m")
        XCTAssertEqual(SportSessionSummary.formatted(seconds: 3_600), "1h")
        XCTAssertEqual(SportSessionSummary.formatted(seconds: 2_700), "45m")
        XCTAssertEqual(SportSessionSummary.formatted(seconds: 30), "30s")
    }

    // MARK: - Helpers

    private func game(
        rpe: Int? = 7,
        result: GameResult? = .win,
        teamScore: Int? = 68,
        opponentScore: Int? = 61
    ) -> SportSessionEntry {
        SportSessionEntry(
            id: "game", sport: .basketball, sessionType: .game,
            performedAt: Date(timeIntervalSince1970: 1_800_000_000),
            duration: 5_400, playingTime: 2_400, rpe: rpe, result: result,
            teamScore: teamScore, opponentScore: opponentScore, note: nil
        )
    }
}
