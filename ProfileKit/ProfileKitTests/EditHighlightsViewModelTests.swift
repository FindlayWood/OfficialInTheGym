//
//  EditHighlightsViewModelTests.swift
//  ProfileKitTests
//
//  Created by Findlay Wood on 04/10/2026.
//

import XCTest
@testable import ProfileKit

@MainActor
final class EditHighlightsViewModelTests: XCTestCase {

    func test_toggle_picksInOrderUpToThree() async {
        let sut = makeSUT(candidates: ["a", "b", "c", "d"])
        await sut.viewModel.load()

        for id in ["c", "a", "d", "b"] { sut.viewModel.toggle(id) }

        // A fourth pick is refused rather than silently dropping the oldest.
        XCTAssertEqual(sut.viewModel.selection, ["c", "a", "d"])
        XCTAssertEqual(sut.viewModel.position(of: "a"), 2)
        XCTAssertNil(sut.viewModel.position(of: "b"))
    }

    func test_toggle_unpicksAPickedExercise() async {
        let sut = makeSUT(pinned: ["a", "b"], candidates: ["a", "b"])
        await sut.viewModel.load()

        sut.viewModel.toggle("a")

        XCTAssertEqual(sut.viewModel.selection, ["b"])
    }

    // A pin whose stats are gone cannot be shown, so it must not count
    // against the three.
    func test_load_dropsPinsWithNoCandidate() async {
        let sut = makeSUT(pinned: ["gone", "a"], candidates: ["a", "b"])

        await sut.viewModel.load()

        XCTAssertEqual(sut.viewModel.selection, ["a"])
    }

    func test_save_writesThePicksAndReportsThemInOrder() async {
        let sut = makeSUT(candidates: ["a", "b", "c"])
        await sut.viewModel.load()
        sut.viewModel.toggle("c")
        sut.viewModel.toggle("a")

        await sut.viewModel.save()

        XCTAssertEqual(sut.content.receivedMessages.last, .setPinned(["c", "a"]))
        XCTAssertEqual(sut.log.saved?.isPinned, true)
        XCTAssertEqual(sut.log.saved?.highlights.map(\.exerciseId), ["c", "a"])
        XCTAssertTrue(sut.log.finished)
    }

    // Automatic previews exactly what the server will show: candidates come
    // most-trained first, as the server ranks them.
    func test_save_automaticReportsTheTopThreeCandidates() async {
        let sut = makeSUT(pinned: ["d"], candidates: ["a", "b", "c", "d"])
        await sut.viewModel.load()
        sut.viewModel.useAutomatic()

        await sut.viewModel.save()

        XCTAssertEqual(sut.content.receivedMessages.last, .setPinned([]))
        XCTAssertEqual(sut.log.saved?.isPinned, false)
        XCTAssertEqual(sut.log.saved?.highlights.map(\.exerciseId), ["a", "b", "c"])
    }

    func test_save_closesWithoutWritingWhenNothingChanged() async {
        let sut = makeSUT(pinned: ["a"], candidates: ["a", "b"])
        await sut.viewModel.load()

        await sut.viewModel.save()

        XCTAssertFalse(sut.content.receivedMessages.contains { if case .setPinned = $0 { true } else { false } })
        XCTAssertTrue(sut.log.finished)
    }

    func test_save_staysOpenWithAnErrorOnFailure() async {
        let sut = makeSUT(candidates: ["a"])
        await sut.viewModel.load()
        sut.viewModel.toggle("a")
        sut.content.writeError = anyError

        await sut.viewModel.save()

        XCTAssertNotNil(sut.viewModel.errorMessage)
        XCTAssertNil(sut.log.saved)
        XCTAssertFalse(sut.log.finished)
    }

    // MARK: - Helpers

    private final class Log {
        var saved: ProfileHighlights?
        var finished = false
    }

    private func makeSUT(
        pinned: [String] = [],
        candidates: [String]
    ) -> (viewModel: EditHighlightsViewModel, content: ContentServicesSpy, log: Log) {
        let content = ContentServicesSpy()
        content.candidatesResult = .success(candidates.map {
            ProfileHighlight(exerciseId: $0, exerciseName: $0, maxWeightKilograms: 50, maxTimeSeconds: 0, isTimeBased: false)
        })
        let log = Log()
        let viewModel = EditHighlightsViewModel(pinned: pinned, loader: content, writer: content)
        viewModel.onSaved = { log.saved = $0 }
        viewModel.onFinished = { log.finished = true }
        return (viewModel, content, log)
    }
}

private let anyError = NSError(domain: "test", code: 0)
