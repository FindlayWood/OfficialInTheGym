//
//  DiscoverSearchQueryTests.swift
//  DiscoverKitTests
//
//  Created by Findlay Wood on 10/10/2026.
//

import XCTest
@testable import DiscoverKit

final class DiscoverSearchQueryTests: XCTestCase {

    // Must split exactly as the server's searchWords does, or a token the
    // server stored is one the app can never ask for.
    func test_words_lowercasesFoldsAccentsAndSplitsOnNonAlphanumerics() {
        XCTAssertEqual(DiscoverSearchQuery.words("  Café-Style: 5x5 UPPER! "), ["cafe", "style", "5x5", "upper"])
    }

    func test_lookupToken_deliversTheLongestWord() {
        XCTAssertEqual(DiscoverSearchQuery.lookupToken(for: ["back", "squat"]), "squat")
    }

    // The server stores prefixes of at most maxTokenLength characters; asking
    // for a longer one would find nothing.
    func test_lookupToken_cutsALongWordToTheStoredLength() {
        let token = DiscoverSearchQuery.lookupToken(for: ["abcdefghijklmnopqrstuvwxyz"])

        XCTAssertEqual(token?.count, DiscoverSearchQuery.maxTokenLength)
    }

    func test_lookupToken_deliversNilForNoWords() {
        XCTAssertNil(DiscoverSearchQuery.lookupToken(for: []))
    }

    func test_matches_findsAWorkoutByALaterWord() {
        XCTAssertTrue(DiscoverSearchQuery.matches(["upper"], in: ["Saturday Upper"]))
    }

    func test_matches_requiresEveryWordInAnyOrder() {
        XCTAssertTrue(DiscoverSearchQuery.matches(["sq", "back"], in: ["Back Squat"]))
        XCTAssertFalse(DiscoverSearchQuery.matches(["back", "squat"], in: ["Back Row"]))
    }

    // Word starts only: the server's tokens cannot answer the middle of a word,
    // and checking more loosely here would disagree with what was fetched.
    func test_matches_doesNotMatchInsideAWord() {
        XCTAssertFalse(DiscoverSearchQuery.matches(["quat"], in: ["Back Squat"]))
    }

    func test_matches_searchesEveryTextGiven() {
        XCTAssertTrue(DiscoverSearchQuery.matches(["wood"], in: ["Findlay", "f_wood"]))
    }
}
