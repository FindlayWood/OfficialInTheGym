//
//  DiscoverWorkoutCommunityTests.swift
//  DiscoverKitTests
//
//  Created by Findlay Wood on 18/11/2026.
//

import XCTest
@testable import DiscoverKit

final class DiscoverWorkoutCommunityTests: XCTestCase {

    func test_decode_deliversCommunityFromTheCard() throws {
        let json = """
        {"templateId": "w1", "title": "Legs", "exerciseCount": 4, "isPublic": true,
         "community": {"peopleCount": 5, "sessionCount": 12, "averageDurationSeconds": 2700, "averageRPE": 7.5}}
        """

        let sut = try JSONDecoder().decode(DiscoverWorkoutCard.self, from: Data(json.utf8))

        XCTAssertEqual(sut.community, DiscoverWorkoutCommunity(
            peopleCount: 5, sessionCount: 12, averageDurationSeconds: 2700, averageRPE: 7.5
        ))
    }

    // Every card written before the function, and every one under three
    // people, has no community; a required field would fail them all.
    func test_decode_deliversNoCommunityWhenAbsent() throws {
        let json = """
        {"templateId": "w1", "title": "Legs", "exerciseCount": 4, "isPublic": true}
        """

        let sut = try JSONDecoder().decode(DiscoverWorkoutCard.self, from: Data(json.utf8))

        XCTAssertNil(sut.community)
    }

    // An average no session carried is left off by the server, never 0.
    func test_decode_deliversMissingAveragesAsNil() throws {
        let json = #"{"peopleCount": 3, "sessionCount": 3}"#

        let sut = try JSONDecoder().decode(DiscoverWorkoutCommunity.self, from: Data(json.utf8))

        XCTAssertNil(sut.averageDurationSeconds)
        XCTAssertNil(sut.averageRPE)
    }

    func test_isShowable_deliversTrueFromThreePeople() {
        XCTAssertFalse(DiscoverWorkoutCommunity(peopleCount: 2, sessionCount: 5).isShowable)
        XCTAssertTrue(DiscoverWorkoutCommunity(peopleCount: 3, sessionCount: 3).isShowable)
    }

    func test_formatDuration_deliversMinutesThenHours() {
        XCTAssertEqual(DiscoverWorkoutCommunitySection.formatDuration(20), "1 min")
        XCTAssertEqual(DiscoverWorkoutCommunitySection.formatDuration(2880), "48 min")
        XCTAssertEqual(DiscoverWorkoutCommunitySection.formatDuration(3900), "1h 05m")
    }

    func test_footnote_deliversSessionsAndPeople() {
        XCTAssertEqual(
            DiscoverWorkoutCommunitySection.footnote(DiscoverWorkoutCommunity(peopleCount: 14, sessionCount: 41)),
            "41 sessions by 14 people"
        )
    }
}
