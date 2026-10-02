//
//  DiscoverRatingViewModelTests.swift
//  DiscoverKitTests
//
//  Created by Findlay Wood on 30/09/2026.
//

import XCTest
@testable import DiscoverKit

@MainActor
final class DiscoverRatingViewModelTests: XCTestCase {

    func test_load_deliversSummaryAndMyRating() async {
        let sut = makeSUT(loadedSummary: RatingSummary(count: 5, sum: 40), myRating: 7)

        await sut.viewModel.load()

        XCTAssertEqual(sut.viewModel.summary, RatingSummary(count: 5, sum: 40))
        XCTAssertEqual(sut.viewModel.myRating, 7)
    }

    // The screen must not wait seconds for the Cloud Function's recount before
    // the average reflects the tap.
    func test_rate_updatesSummaryBeforeTheServerRecounts() async {
        let sut = makeSUT(initialSummary: RatingSummary(count: 2, sum: 12))

        await sut.viewModel.rate(8)

        XCTAssertEqual(sut.viewModel.myRating, 8)
        XCTAssertEqual(sut.viewModel.summary, RatingSummary(count: 3, sum: 20))
        XCTAssertEqual(sut.writer.receivedMessages, [.setRating(8, .workout(id: "w1"))])
    }

    func test_rate_revertsSummaryAndRatingWhenSaveFails() async {
        let sut = makeSUT(initialSummary: RatingSummary(count: 2, sum: 12), writeError: anyError)

        await sut.viewModel.rate(8)

        XCTAssertNil(sut.viewModel.myRating)
        XCTAssertEqual(sut.viewModel.summary, RatingSummary(count: 2, sum: 12))
        XCTAssertTrue(sut.viewModel.didFailToSave)
    }

    func test_rate_doesNothingWhenRatingOwnWorkout() async {
        let sut = makeSUT(canRate: false)

        await sut.viewModel.rate(8)

        XCTAssertNil(sut.viewModel.myRating)
        XCTAssertTrue(sut.writer.receivedMessages.isEmpty)
    }

    func test_rate_doesNotWriteTheSameRatingAgain() async {
        let sut = makeSUT()
        await sut.viewModel.rate(8)

        await sut.viewModel.rate(8)

        XCTAssertEqual(sut.writer.receivedMessages.count, 1)
    }

    // MARK: - Helpers

    private func makeSUT(
        initialSummary: RatingSummary = .empty,
        loadedSummary: RatingSummary = .empty,
        myRating: Int? = nil,
        canRate: Bool = true,
        writeError: Error? = nil
    ) -> (viewModel: DiscoverRatingViewModel, writer: RatingWriterSpy) {
        let writer = RatingWriterSpy(error: writeError)
        let viewModel = DiscoverRatingViewModel(
            subject: .workout(id: "w1"),
            initialSummary: initialSummary,
            canRate: canRate,
            summaryLoader: PreviewRatingSummaryLoader(summary: loadedSummary),
            myRatingLoader: PreviewMyRatingLoader(rating: myRating),
            writer: writer
        )
        return (viewModel, writer)
    }
}

private let anyError = NSError(domain: "test", code: 0)
