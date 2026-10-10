//
//  DiscoverExerciseMatcherTests.swift
//  DiscoverKitTests
//
//  Created by Findlay Wood on 10/10/2026.
//

import XCTest
@testable import DiscoverKit

final class DiscoverExerciseMatcherTests: XCTestCase {

    func test_search_findsAnyWordOfTheName() {
        let sut = search("squat")

        XCTAssertEqual(sut, ["Squat", "Back Squat", "Bulgarian Split Squat"])
    }

    // The reason exercises are searched on the device: Firestore cannot match
    // the middle of a word.
    func test_search_findsTheInsideOfAWord() {
        XCTAssertEqual(search("quat"), ["Squat", "Back Squat", "Bulgarian Split Squat"])
    }

    // A swap of two letters is the commonest typo; plain Levenshtein counts it
    // as two edits and would reject it.
    func test_search_forgivesTwoSwappedLetters() {
        XCTAssertEqual(search("sqaut"), ["Squat", "Back Squat", "Bulgarian Split Squat"])
    }

    func test_search_forgivesOneTypoAtTheStartOfAWord() {
        XCTAssertEqual(search("bwnch"), ["Bench Press", "Incline Bench Press"])
    }

    // At three letters one edit away is almost anything; "row" would match
    // "rot" and "raw".
    func test_search_doesNotForgiveATypoInAShortWord() {
        XCTAssertEqual(search("rwo"), [])
    }

    func test_search_requiresEveryWord() {
        XCTAssertEqual(search("back sq"), ["Back Squat"])
    }

    // A name that starts with what was typed is the likeliest one wanted.
    func test_search_ranksANameStartingWithTheQueryFirst() {
        XCTAssertEqual(search("bench").first, "Bench Press")
    }

    func test_search_ranksAWordStartAboveTheInsideOfAWord() {
        let sut = search("row", in: ["Narrow Grip Press", "Bent Over Row"])

        XCTAssertEqual(sut, ["Bent Over Row", "Narrow Grip Press"])
    }

    func test_search_deliversNothingForAnEmptyQuery() {
        XCTAssertEqual(search("  "), [])
    }

    func test_search_capsAtTheLimit() {
        XCTAssertEqual(search("s", limit: 2).count, 2)
    }

    func test_editDistance_countsASwapAsOneEdit() {
        XCTAssertEqual(DiscoverExerciseMatcher.editDistance("sqaut", "squat"), 1)
        XCTAssertEqual(DiscoverExerciseMatcher.editDistance("squat", "squat"), 0)
        XCTAssertEqual(DiscoverExerciseMatcher.editDistance("squat", "sprint"), 4)
    }

    // MARK: - Helpers

    private func search(_ query: String, in names: [String] = catalogue, limit: Int = 25) -> [String] {
        let cards = names.map { DiscoverExerciseCard(exerciseId: $0, name: $0, category: nil) }
        return DiscoverExerciseMatcher.search(query, in: cards, limit: limit).map(\.name)
    }
}

private let catalogue = [
    "Back Squat", "Bench Press", "Bent Over Row", "Bulgarian Split Squat",
    "Deadlift", "Incline Bench Press", "Squat", "Pull Up"
]
