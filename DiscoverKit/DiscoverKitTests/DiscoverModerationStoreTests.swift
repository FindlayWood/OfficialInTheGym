//
//  DiscoverModerationStoreTests.swift
//  DiscoverKitTests
//
//  Created by Findlay Wood on 30/09/2026.
//

import XCTest
@testable import DiscoverKit

@MainActor
final class DiscoverModerationStoreTests: XCTestCase {

    // A report must hide the thing from its reporter at once — before, and
    // whether or not, enough others agree for the server to hide it.
    func test_report_hidesTheTargetStraightAway() async {
        let (sut, spy) = makeSUT()

        let sent = await sut.report(.clip(id: "c1"), reason: .spam)

        XCTAssertTrue(sent)
        XCTAssertTrue(sut.hides(clip(id: "c1", by: "u2")))
        XCTAssertEqual(spy.receivedMessages, [.report(.clip(id: "c1"), .spam)])
    }

    func test_report_showsTheTargetAgainWhenSendingFails() async {
        let (sut, spy) = makeSUT()
        spy.error = anyError

        let sent = await sut.report(.clip(id: "c1"), reason: .spam)

        XCTAssertFalse(sent)
        XCTAssertFalse(sut.hides(clip(id: "c1", by: "u2")))
    }

    // One report per user per target — the server would refuse a second.
    func test_report_doesNotSendTheSameReportTwice() async {
        let (sut, spy) = makeSUT()

        await sut.report(.tag("legs"), reason: .hate)
        await sut.report(.tag("legs"), reason: .other)

        XCTAssertEqual(spy.receivedMessages.count, 1)
    }

    func test_setBlocked_hidesTheUsersCommentsClipsAndWorkouts() async {
        let (sut, _) = makeSUT()

        await sut.setBlocked(true, userId: "u2")

        XCTAssertTrue(sut.hides(comment(by: "u2"), on: .workout(id: "w1")))
        XCTAssertTrue(sut.hides(clip(id: "c1", by: "u2")))
        XCTAssertTrue(sut.hides(workout(by: "u2")))
        XCTAssertFalse(sut.hides(comment(by: "u3"), on: .workout(id: "w1")))
    }

    func test_setBlocked_unblockingShowsTheUserAgain() async {
        let (sut, _) = makeSUT()
        await sut.setBlocked(true, userId: "u2")

        await sut.setBlocked(false, userId: "u2")

        XCTAssertFalse(sut.hides(clip(id: "c1", by: "u2")))
    }

    func test_setBlocked_revertsWhenSavingFails() async {
        let (sut, spy) = makeSUT()
        spy.error = anyError

        let saved = await sut.setBlocked(true, userId: "u2")

        XCTAssertFalse(saved)
        XCTAssertFalse(sut.isBlocked("u2"))
    }

    // Reports and blocks from earlier sessions must keep things hidden.
    func test_loadIfNeeded_deliversEarlierBlocksAndReports() async {
        let (sut, spy) = makeSUT()
        spy.blocked = ["u2"]
        spy.reported = [.comment(commentId: "x", subject: .workout(id: "w1"))]

        await sut.loadIfNeeded()

        XCTAssertTrue(sut.isBlocked("u2"))
        XCTAssertTrue(sut.hides(comment(id: "x", by: "u3"), on: .workout(id: "w1")))
    }

    // A reported comment is hidden only on the subject it was reported on:
    // comment ids are unique within a subject, not across them.
    func test_hides_reportedCommentOnlyOnItsOwnSubject() async {
        let (sut, _) = makeSUT()

        await sut.report(.comment(commentId: "x", subject: .workout(id: "w1")), reason: .spam)

        XCTAssertTrue(sut.hides(comment(id: "x", by: "u3"), on: .workout(id: "w1")))
        XCTAssertFalse(sut.hides(comment(id: "x", by: "u3"), on: .clip(id: "w1")))
    }

    // MARK: - Helpers

    private func makeSUT() -> (DiscoverModerationStore, ModerationSpy) {
        let spy = ModerationSpy()
        let sut = DiscoverModerationStore(blockedLoader: spy, reportsLoader: spy, reportWriter: spy, blockWriter: spy)
        return (sut, spy)
    }

    private func comment(id: String = "c1", by authorId: String) -> DiscoverComment {
        DiscoverComment(commentId: id, authorId: authorId, text: "hi", parentId: nil, createdAt: nil)
    }

    private func clip(id: String, by userId: String) -> DiscoverClipCard {
        DiscoverClipCard(clipId: id, exerciseId: nil, exerciseName: nil, videoURL: nil, thumbnailURL: nil,
                         durationSeconds: nil, createdBy: userId, uploadedAt: nil)
    }

    private func workout(by userId: String) -> DiscoverWorkoutCard {
        DiscoverWorkoutCard(templateId: "w1", title: "Legs", createdBy: userId, exerciseCount: 3, createdAt: nil, isPublic: true)
    }
}

private let anyError = NSError(domain: "test", code: 0)
