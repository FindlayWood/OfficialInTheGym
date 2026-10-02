//
//  DiscoverWorkoutDetailViewModelTests.swift
//  DiscoverKitTests
//
//  Created by Findlay Wood on 02/10/2026.
//

import XCTest
@testable import DiscoverKit

@MainActor
final class DiscoverWorkoutDetailViewModelTests: XCTestCase {

    func test_load_deliversContentsAndAuthor() async {
        let (sut, _) = makeSUT()

        await sut.load()

        guard case .loaded(let detail) = sut.detail else { return XCTFail("Expected loaded detail") }
        XCTAssertEqual(detail.exercises.count, 3)
        XCTAssertEqual(sut.authorName, "Findlay")
        XCTAssertEqual(sut.saveState, .idle)
    }

    // A workout saved last week must read "Saved", not invite a second copy.
    func test_load_deliversSavedWhenTheLibraryHoldsACopy() async {
        let (sut, spy) = makeSUT()
        spy.alreadySaved = true

        await sut.load()

        XCTAssertEqual(sut.saveState, .saved)
    }

    func test_save_savesACopyOnce() async {
        let (sut, spy) = makeSUT()
        await sut.load()

        await sut.save()
        await sut.save()

        XCTAssertEqual(spy.receivedMessages, [.saveCopy("w1")])
        XCTAssertEqual(sut.saveState, .saved)
    }

    func test_save_deliversFailedAndAllowsRetry() async {
        let (sut, spy) = makeSUT()
        spy.error = NSError(domain: "test", code: 0)
        await sut.load()

        await sut.save()
        XCTAssertEqual(sut.saveState, .failed)

        spy.error = nil
        await sut.save()
        XCTAssertEqual(sut.saveState, .saved)
    }

    // No saver means the user's own workout, or the coach tab bar with no
    // library — there is nothing to save into, so nothing is offered.
    func test_init_deliversUnavailableWithoutASaver() async {
        let sut = DiscoverWorkoutDetailViewModel(
            templateId: "w1", createdBy: "u1", detailLoader: PreviewWorkoutLoaders(),
            profileLoader: PreviewUserProfileLoader(), copySaver: nil, copyChecker: nil
        )

        await sut.load()
        await sut.save()

        XCTAssertEqual(sut.saveState, .unavailable)
    }

    // MARK: - Helpers

    private func makeSUT() -> (DiscoverWorkoutDetailViewModel, WorkoutCopySaverSpy) {
        let spy = WorkoutCopySaverSpy()
        let sut = DiscoverWorkoutDetailViewModel(
            templateId: "w1",
            createdBy: "u1",
            detailLoader: PreviewWorkoutLoaders(),
            profileLoader: PreviewUserProfileLoader(),
            copySaver: spy,
            copyChecker: spy
        )
        return (sut, spy)
    }
}
