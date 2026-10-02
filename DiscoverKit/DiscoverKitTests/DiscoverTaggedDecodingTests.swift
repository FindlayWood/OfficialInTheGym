//
//  DiscoverTaggedDecodingTests.swift
//  DiscoverKitTests
//
//  Created by Findlay Wood on 30/09/2026.
//

import XCTest
@testable import DiscoverKit

final class DiscoverTaggedDecodingTests: XCTestCase {

    // An index entry is the card's projection plus voteCount in one flat
    // document; the card must decode from the same keys, not a nested object.
    func test_decode_deliversCardAndVoteCountFromOneFlatDocument() throws {
        let json = """
        {"exerciseId": "squat", "name": "Squat", "category": "lower_body", "subjectId": "squat", "voteCount": 7}
        """

        let sut = try JSONDecoder().decode(DiscoverTagged<DiscoverExerciseCard>.self, from: Data(json.utf8))

        XCTAssertEqual(sut.card.name, "Squat")
        XCTAssertEqual(sut.voteCount, 7)
        XCTAssertEqual(sut.id, "squat")
    }

    func test_decode_deliversZeroVotesWhenAbsent() throws {
        let json = """
        {"exerciseId": "squat", "name": "Squat"}
        """

        let sut = try JSONDecoder().decode(DiscoverTagged<DiscoverExerciseCard>.self, from: Data(json.utf8))

        XCTAssertEqual(sut.voteCount, 0)
    }
}
