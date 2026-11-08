//
//  MyDayNewSportManagerTests.swift
//  MyDayKitTests
//
//  Created by Findlay Wood on 05/11/2026.
//

import XCTest
@testable import MyDayKit

final class MyDayNewSportManagerTests: XCTestCase {

    func test_makeEntry_deliversGameAsFilledIn() {
        let sut = gameForm()

        let entry = sut.makeEntry(id: "id", performedAt: fixedDate)

        XCTAssertEqual(entry, SportSessionEntry(
            id: "id", sport: .basketball, sessionType: .game, performedAt: fixedDate,
            duration: 5_400, playingTime: 2_400, rpe: 7, result: .win,
            teamScore: 68, opponentScore: 61, note: "Good defence"
        ))
    }

    // The form keeps game answers when the type is switched back, so the user
    // does not lose them by tapping the wrong segment. A saved training session
    // must not carry them, or it would read back as a game with a scoreline.
    func test_makeEntry_dropsGameAnswersForTraining() {
        let sut = gameForm()
        sut.sessionType = .training

        let entry = sut.makeEntry(id: "id", performedAt: fixedDate)

        XCTAssertNil(entry.playingTime)
        XCTAssertNil(entry.result)
        XCTAssertNil(entry.teamScore)
        XCTAssertNil(entry.opponentScore)
        XCTAssertEqual(entry.duration, 5_400)
    }

    func test_makeEntry_deliversNilNoteForBlankNote() {
        let sut = gameForm()
        sut.note = "   \n"

        XCTAssertNil(sut.makeEntry(id: "id", performedAt: fixedDate).note)
    }

    func test_makeEntry_trimsNote() {
        let sut = gameForm()
        sut.note = "  Good defence \n"

        XCTAssertEqual(sut.makeEntry(id: "id", performedAt: fixedDate).note, "Good defence")
    }

    // The load shown on the form before saving has to be the load stored.
    func test_sessionLoad_matchesSavedEntry() {
        let sut = gameForm()

        XCTAssertEqual(sut.sessionLoad ?? -1, sut.makeEntry().sessionLoad ?? -2, accuracy: 0.001)
    }

    // MARK: - Helpers

    private let fixedDate = Date(timeIntervalSince1970: 1_800_000_000)

    private func gameForm() -> MyDayNewSportManager {
        let form = MyDayNewSportManager(sport: .basketball)
        form.sessionType = .game
        form.duration = 5_400
        form.playingTime = 2_400
        form.rpe = 7
        form.result = .win
        form.homeScore = 68
        form.awayScore = 61
        form.note = "Good defence"
        return form
    }
}
