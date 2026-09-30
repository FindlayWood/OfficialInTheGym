//
//  DiscoverTaggingViewModelTests.swift
//  DiscoverKitTests
//
//  Created by Findlay Wood on 30/09/2026.
//

import XCTest
@testable import DiscoverKit

@MainActor
final class DiscoverTaggingViewModelTests: XCTestCase {

    // One document holds the user's whole set, so adding a tag writes the set.
    func test_toggle_addsATagAndWritesTheWholeSet() async {
        let sut = makeSUT()
        await sut.viewModel.load()

        await sut.viewModel.toggle("legs")

        XCTAssertEqual(sut.viewModel.myTags, ["hotel", "legs"])
        XCTAssertEqual(sut.viewModel.counts["legs"], 5)
        XCTAssertEqual(sut.writer.receivedMessages, [.setMyTags(["hotel", "legs"], .exercise(id: "squat"))])
    }

    func test_toggle_removesATagAlreadyMine() async {
        let sut = makeSUT()
        await sut.viewModel.load()

        await sut.viewModel.toggle("hotel")

        XCTAssertEqual(sut.viewModel.myTags, [])
        XCTAssertEqual(sut.writer.receivedMessages, [.setMyTags([], .exercise(id: "squat"))])
    }

    func test_toggle_revertsWhenSaveFails() async {
        let sut = makeSUT()
        sut.writer.error = NSError(domain: "test", code: 0)
        await sut.viewModel.load()

        await sut.viewModel.toggle("legs")

        XCTAssertEqual(sut.viewModel.myTags, ["hotel"])
        XCTAssertEqual(sut.viewModel.counts["legs"], 4)
        XCTAssertTrue(sut.viewModel.didFailToSave)
    }

    // The server drops every tag past the tenth; offering an eleventh would
    // accept a tag that never counts.
    func test_toggle_doesNotAddPastTheLimit() async {
        let sut = makeSUT()
        for index in 0..<DiscoverTaggingViewModel.maxMyTags {
            await sut.viewModel.toggle("tag\(index)")
        }

        await sut.viewModel.toggle("onemore")

        XCTAssertEqual(sut.viewModel.myTags.count, DiscoverTaggingViewModel.maxMyTags)
        XCTAssertFalse(sut.viewModel.myTags.contains("onemore"))
    }

    func test_toggle_doesNothingOnOwnWorkout() async {
        let sut = makeSUT(canVote: false)

        await sut.viewModel.toggle("legs")

        XCTAssertTrue(sut.writer.receivedMessages.isEmpty)
    }

    // What is typed is what is stored, so the field shows the normalised tag.
    func test_query_isNormalisedAsItIsTyped() {
        let sut = makeSUT()

        sut.viewModel.query = "Leg Day!"

        XCTAssertEqual(sut.viewModel.query, "legday")
    }

    func test_addQuery_addsTheTypedTagAndClearsTheField() async {
        let sut = makeSUT()
        sut.viewModel.query = "Mobility"

        await sut.viewModel.addQuery()

        XCTAssertEqual(sut.viewModel.myTags, ["mobility"])
        XCTAssertEqual(sut.viewModel.query, "")
    }

    // The user must see their own vote at once, even though nobody else can
    // yet — otherwise tagging a new exercise appears to do nothing.
    func test_shownTags_includesOwnVotesNotYetVisible() async {
        let sut = makeSUT()
        await sut.viewModel.load()

        XCTAssertEqual(sut.viewModel.shownTags, ["legs", "lowerbody", "hotel"])
    }

    func test_votableTags_ranksByVotesThenAlphabetically() async {
        let sut = makeSUT()
        await sut.viewModel.load()

        XCTAssertEqual(sut.viewModel.votableTags, ["legs", "lowerbody", "hotel"])
    }

    // MARK: - Helpers

    private func makeSUT(canVote: Bool = true) -> (viewModel: DiscoverTaggingViewModel, writer: TagVoteWriterSpy) {
        let writer = TagVoteWriterSpy()
        let viewModel = DiscoverTaggingViewModel(
            subject: .exercise(id: "squat"),
            visibleTags: ["legs", "lowerbody"],
            counts: ["legs": 4, "lowerbody": 3, "hotel": 1],
            canVote: canVote,
            normalizer: PreviewTagServices(),
            myTagsLoader: PreviewTagLoaders(),
            writer: writer,
            suggestionLoader: PreviewTagLoaders()
        )
        return (viewModel, writer)
    }
}
