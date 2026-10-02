//
//  RatingSummaryTests.swift
//  DiscoverKitTests
//
//  Created by Findlay Wood on 30/09/2026.
//

import XCTest
@testable import DiscoverKit

final class RatingSummaryTests: XCTestCase {

    func test_average_deliversSumOverCount() {
        let sut = RatingSummary(count: 4, sum: 30)

        XCTAssertEqual(sut.average ?? 0, 7.5, accuracy: 0.0001)
    }

    // No ratings is an absence, not a score of zero — "0.0" on screen would
    // read as the worst possible rating.
    func test_average_deliversNilWithNoRatings() {
        let sut = RatingSummary.empty

        XCTAssertNil(sut.average)
        XCTAssertEqual(sut.formattedAverage, "—")
    }

    func test_formattedAverage_deliversOneDecimalPlace() {
        let sut = RatingSummary(count: 3, sum: 22)

        XCTAssertEqual(sut.formattedAverage, "7.3")
    }

    func test_replacingRating_addsAFirstRating() {
        let sut = RatingSummary(count: 2, sum: 14)

        XCTAssertEqual(sut.replacingRating(nil, with: 9), RatingSummary(count: 3, sum: 23))
    }

    // One rating per user: re-rating must replace, not add, or every change of
    // mind would count as another person's opinion.
    func test_replacingRating_replacesAnEarlierRatingWithoutCountingItTwice() {
        let sut = RatingSummary(count: 3, sum: 23)

        XCTAssertEqual(sut.replacingRating(9, with: 4), RatingSummary(count: 3, sum: 18))
    }
}
