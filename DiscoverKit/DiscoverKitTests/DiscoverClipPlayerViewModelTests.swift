//
//  DiscoverClipPlayerViewModelTests.swift
//  DiscoverKitTests
//
//  Created by Findlay Wood on 30/09/2026.
//

import XCTest
@testable import DiscoverKit

@MainActor
final class DiscoverClipPlayerViewModelTests: XCTestCase {

    func test_finishWatching_reportsPositionLoopsAndDuration() async {
        let sut = makeSUT()
        await sut.viewModel.load()
        sut.viewModel.progressed(to: 0.4)
        sut.viewModel.looped(2)

        sut.viewModel.finishWatching(now: Date().addingTimeInterval(10))

        XCTAssertEqual(sut.recorder.receivedWatches.count, 1)
        let watch = sut.recorder.receivedWatches[0]
        XCTAssertEqual(watch.clipID, "clip1")
        XCTAssertTrue(watch.watchedMoreThanThreeSeconds)
        XCTAssertTrue(watch.watchedFullVideo)
        XCTAssertEqual(watch.closePosition, 0.4, accuracy: 0.0001)
        XCTAssertEqual(watch.loopCount, 2)
    }

    func test_finishWatching_reportsAShortWatchAsUnderThreeSeconds() async {
        let sut = makeSUT()
        await sut.viewModel.load()

        sut.viewModel.finishWatching(now: Date().addingTimeInterval(1))

        XCTAssertFalse(sut.recorder.receivedWatches[0].watchedMoreThanThreeSeconds)
        XCTAssertFalse(sut.recorder.receivedWatches[0].watchedFullVideo)
    }

    // onDisappear can fire more than once; each would otherwise be counted as
    // another view of the clip.
    func test_finishWatching_reportsOnlyOncePerVisit() async {
        let sut = makeSUT()
        await sut.viewModel.load()

        sut.viewModel.finishWatching()
        sut.viewModel.finishWatching()

        XCTAssertEqual(sut.recorder.receivedWatches.count, 1)
    }

    func test_toggleLike_likesAndCountsBeforeTheServerConfirms() async {
        let sut = makeSUT()

        await sut.viewModel.toggleLike()

        XCTAssertTrue(sut.viewModel.isLiked)
        XCTAssertEqual(sut.viewModel.likeCount, 4)
        XCTAssertEqual(sut.likes.receivedMessages, [.setLiked(true, .clip(id: "clip1"))])
    }

    func test_toggleLike_revertsWhenSaveFails() async {
        let sut = makeSUT()
        sut.likes.error = NSError(domain: "test", code: 0)

        await sut.viewModel.toggleLike()

        XCTAssertFalse(sut.viewModel.isLiked)
        XCTAssertEqual(sut.viewModel.likeCount, 3)
        XCTAssertTrue(sut.viewModel.didFailToLike)
    }

    // MARK: - Helpers

    private func makeSUT() -> (viewModel: DiscoverClipPlayerViewModel, recorder: ClipWatchRecorderSpy, likes: LikeWriterSpy) {
        let recorder = ClipWatchRecorderSpy()
        let likes = LikeWriterSpy()
        let card = DiscoverClipCard(
            clipId: "clip1", exerciseId: "squat", exerciseName: "Squat", videoURL: nil, thumbnailURL: nil,
            durationSeconds: 12, createdBy: "u1", uploadedAt: nil, likeCount: 3
        )
        let viewModel = DiscoverClipPlayerViewModel(card: card, likeLoader: PreviewLikeLoader(), likeWriter: likes, recorder: recorder)
        return (viewModel, recorder, likes)
    }
}
