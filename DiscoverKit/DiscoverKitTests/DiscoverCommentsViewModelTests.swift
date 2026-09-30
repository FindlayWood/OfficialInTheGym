//
//  DiscoverCommentsViewModelTests.swift
//  DiscoverKitTests
//
//  Created by Findlay Wood on 30/09/2026.
//

import XCTest
@testable import DiscoverKit

@MainActor
final class DiscoverCommentsViewModelTests: XCTestCase {

    func test_loadFirstPageIfNeeded_deliversThreadsAndResolvesAuthors() async {
        let sut = makeSUT()

        await sut.viewModel.loadFirstPageIfNeeded()

        XCTAssertEqual(sut.viewModel.threads.map(\.id), ["c1", "c2", "c3"])
        XCTAssertEqual(sut.viewModel.author(of: sut.viewModel.threads[0].comment), .name("Findlay", initial: "F"))
    }

    // An author not yet looked up is still loading. Drawing "Deleted user"
    // before the lookup returns would flash it on every comment.
    func test_author_deliversLoadingBeforeTheLookup() {
        let sut = makeSUT()
        let comment = DiscoverComment(commentId: "x", authorId: "u9", text: "hi", parentId: nil, createdAt: nil)

        XCTAssertEqual(sut.viewModel.author(of: comment), .loading)
    }

    // A comment with no author left is an anonymised one (account deleted).
    func test_author_deliversDeletedWhenTheCommentHasNoAuthor() async {
        let sut = makeSUT()
        await sut.viewModel.loadFirstPageIfNeeded()

        XCTAssertEqual(sut.viewModel.author(of: sut.viewModel.threads[1].comment), .deleted)
    }

    func test_post_insertsTopLevelCommentFirst() async {
        let sut = makeSUT()
        await sut.viewModel.loadFirstPageIfNeeded()
        sut.viewModel.draft = "  Great workout  "

        await sut.viewModel.post()

        XCTAssertEqual(sut.writer.receivedMessages, [.post("Great workout", parentId: nil)])
        XCTAssertEqual(sut.viewModel.threads.first?.comment.text, "Great workout")
        XCTAssertEqual(sut.viewModel.draft, "")
    }

    func test_post_appendsReplyToItsThreadAndCountsIt() async {
        let sut = makeSUT()
        await sut.viewModel.loadFirstPageIfNeeded()
        sut.viewModel.replyingTo = sut.viewModel.threads[2].comment
        sut.viewModel.draft = "Agreed"

        await sut.viewModel.post()

        XCTAssertEqual(sut.writer.receivedMessages, [.post("Agreed", parentId: "c3")])
        XCTAssertEqual(sut.viewModel.threads[2].replies.map(\.text), ["Agreed"])
        XCTAssertEqual(sut.viewModel.threads[2].comment.replyCount, 1)
        XCTAssertTrue(sut.viewModel.threads[2].isExpanded)
        XCTAssertNil(sut.viewModel.replyingTo)
    }

    // A failed post must leave the draft in place — it is what the user needs
    // to try again.
    func test_post_keepsTheDraftWhenPostingFails() async {
        let sut = makeSUT()
        sut.writer.error = anyError
        sut.viewModel.draft = "Great workout"

        await sut.viewModel.post()

        XCTAssertEqual(sut.viewModel.draft, "Great workout")
        XCTAssertNotNil(sut.viewModel.actionError)
    }

    func test_canPost_deliversFalseForBlankOrTooLongText() {
        let sut = makeSUT()

        sut.viewModel.draft = "   "
        XCTAssertFalse(sut.viewModel.canPost)

        sut.viewModel.draft = String(repeating: "a", count: DiscoverCommentsViewModel.maxLength + 1)
        XCTAssertFalse(sut.viewModel.canPost)
    }

    func test_toggleLike_likesAndCountsBeforeTheServerConfirms() async {
        let sut = makeSUT()
        await sut.viewModel.loadFirstPageIfNeeded()
        let comment = sut.viewModel.threads[0].comment

        await sut.viewModel.toggleLike(comment)

        XCTAssertTrue(sut.viewModel.isLiked(comment))
        XCTAssertEqual(sut.viewModel.threads[0].comment.likeCount, 5)
        XCTAssertEqual(sut.likes.receivedMessages, [.setLiked(true, .comment(commentId: "c1", subject: .workout(id: "w1")))])
    }

    func test_toggleLike_revertsWhenSaveFails() async {
        let sut = makeSUT()
        sut.likes.error = anyError
        await sut.viewModel.loadFirstPageIfNeeded()
        let comment = sut.viewModel.threads[0].comment

        await sut.viewModel.toggleLike(comment)

        XCTAssertFalse(sut.viewModel.isLiked(comment))
        XCTAssertEqual(sut.viewModel.threads[0].comment.likeCount, 4)
    }

    func test_remove_marksOwnCommentRemovedAndClearsItsText() async {
        let sut = makeSUT(currentUserId: "u1")
        await sut.viewModel.loadFirstPageIfNeeded()

        await sut.viewModel.remove(sut.viewModel.threads[0].comment)

        XCTAssertEqual(sut.writer.receivedMessages, [.remove("c1")])
        XCTAssertTrue(sut.viewModel.threads[0].comment.isRemoved)
        XCTAssertEqual(sut.viewModel.threads[0].comment.text, "")
    }

    func test_remove_doesNothingToSomeoneElsesComment() async {
        let sut = makeSUT(currentUserId: "u2")
        await sut.viewModel.loadFirstPageIfNeeded()

        await sut.viewModel.remove(sut.viewModel.threads[0].comment)

        XCTAssertTrue(sut.writer.receivedMessages.isEmpty)
        XCTAssertFalse(sut.viewModel.threads[0].comment.isRemoved)
    }

    func test_remove_restoresTheCommentWhenRemovalFails() async {
        let sut = makeSUT(currentUserId: "u1")
        sut.writer.error = anyError
        await sut.viewModel.loadFirstPageIfNeeded()

        await sut.viewModel.remove(sut.viewModel.threads[0].comment)

        XCTAssertFalse(sut.viewModel.threads[0].comment.isRemoved)
        XCTAssertNotNil(sut.viewModel.actionError)
    }

    func test_toggleReplies_loadsRepliesOnFirstOpen() async {
        let sut = makeSUT()
        await sut.viewModel.loadFirstPageIfNeeded()

        await sut.viewModel.toggleReplies(sut.viewModel.threads[0])

        XCTAssertTrue(sut.viewModel.threads[0].isExpanded)
        XCTAssertEqual(sut.viewModel.threads[0].replies.map(\.id), ["r1", "r2"])
    }

    // MARK: - Helpers

    private func makeSUT(currentUserId: String = "me") -> (
        viewModel: DiscoverCommentsViewModel, writer: CommentWriterSpy, likes: LikeWriterSpy
    ) {
        let writer = CommentWriterSpy()
        let likes = LikeWriterSpy()
        let viewModel = DiscoverCommentsViewModel(
            subject: .workout(id: "w1"),
            currentUserId: currentUserId,
            commentLoader: PreviewCommentLoader(),
            replyLoader: PreviewCommentLoader(),
            commentWriter: writer,
            commentRemover: writer,
            likeLoader: PreviewLikeLoader(),
            likeWriter: likes,
            profileLoader: PreviewUserProfileLoader()
        )
        return (viewModel, writer, likes)
    }
}

private let anyError = NSError(domain: "test", code: 0)
