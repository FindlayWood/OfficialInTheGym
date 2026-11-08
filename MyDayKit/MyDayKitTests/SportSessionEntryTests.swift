//
//  SportSessionEntryTests.swift
//  MyDayKitTests
//
//  Created by Findlay Wood on 05/11/2026.
//

import XCTest
@testable import MyDayKit

final class SportSessionEntryTests: XCTestCase {

    func test_sessionLoad_deliversDurationMinutesTimesRPEForTraining() {
        let sut = SportSessionEntry.sessionLoad(type: .training, duration: 3_600, playingTime: 0, rpe: 6)

        XCTAssertEqual(sut ?? -1, 360, accuracy: 0.001)
    }

    // Time on the bench is not training load. Counting the whole game would
    // give a forty-minute substitute the load of a full ninety.
    func test_sessionLoad_deliversPlayingTimeNotGameDurationForGame() {
        let sut = SportSessionEntry.sessionLoad(type: .game, duration: 5_400, playingTime: 2_400, rpe: 7)

        XCTAssertEqual(sut ?? -1, 280, accuracy: 0.001)
    }

    func test_sessionLoad_fallsBackToDurationForGameWithoutPlayingTime() {
        let sut = SportSessionEntry.sessionLoad(type: .game, duration: 3_000, playingTime: 0, rpe: 5)

        XCTAssertEqual(sut ?? -1, 250, accuracy: 0.001)
    }

    // Zero would claim a session that was measured and felt easy; no RPE
    // means it was never measured.
    func test_sessionLoad_deliversNilWithoutRPE() {
        XCTAssertNil(SportSessionEntry.sessionLoad(type: .training, duration: 3_600, playingTime: 0, rpe: nil))
    }

    func test_sessionLoad_deliversNilWithoutTime() {
        XCTAssertNil(SportSessionEntry.sessionLoad(type: .training, duration: 0, playingTime: 0, rpe: 6))
    }

    func test_sessionLoad_onEntryMatchesTheSharedRule() {
        let sut = SportSessionEntry.basketballGame()

        XCTAssertEqual(sut.sessionLoad ?? -1, 280, accuracy: 0.001)
    }

    // Every day file written before sports existed has no `sports` key. If
    // the field were not optional, every one of them would fail to decode
    // and MyDay would show those days as empty.
    func test_dayDecoding_deliversNilSportsForDayWrittenBeforeSports() throws {
        let json = #"{"id":"day","date":0,"exercises":[],"workouts":[]}"#

        let sut = try JSONDecoder().decode(MyDayFullDayModel.self, from: Data(json.utf8))

        XCTAssertNil(sut.sports)
    }

    func test_dayEncoding_roundTripsSports() throws {
        let day = MyDayFullDayModel(id: "day", date: Date(timeIntervalSince1970: 0), exercises: [], workouts: [], sports: [.basketballGame(), .golfRound()])

        let sut = try JSONDecoder().decode(MyDayFullDayModel.self, from: JSONEncoder().encode(day))

        XCTAssertEqual(sut.sports, [.basketballGame(), .golfRound()])
    }
}
