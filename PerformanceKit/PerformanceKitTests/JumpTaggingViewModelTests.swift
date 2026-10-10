//
//  JumpTaggingViewModelTests.swift
//  PerformanceKitTests
//
//  Created by Findlay Wood on 10/10/2026.
//

import XCTest
@testable import PerformanceKit

final class JumpTaggingViewModelTests: XCTestCase {

    func test_nextEvent_followsThePlan() {
        var sut = JumpTaggingViewModel(kind: .verticalJump)

        XCTAssertEqual(sut.nextEvent, .takeOff)
        _ = sut.tag(at: 1.25)
        XCTAssertEqual(sut.nextEvent, .landing)
        _ = sut.tag(at: 1.75)
        XCTAssertNil(sut.nextEvent)
        XCTAssertTrue(sut.isComplete)
    }

    func test_prompt_namesTheNextEventAndCountsTags() {
        var sut = JumpTaggingViewModel(kind: .verticalJump)

        XCTAssertEqual(sut.prompt, "Tag take-off (1 of 2)")
        _ = sut.tag(at: 1.25)
        XCTAssertEqual(sut.prompt, "Tag landing (2 of 2)")
    }

    func test_attempt_deliversTheJumpOnceEveryEventIsTagged() throws {
        var sut = JumpTaggingViewModel(kind: .verticalJump)
        _ = sut.tag(at: 1.25)
        XCTAssertNil(sut.attempt)

        _ = sut.tag(at: 1.75)

        let attempt = try XCTUnwrap(sut.attempt)
        XCTAssertEqual(attempt.height, 30.66, accuracy: 0.0001)
        XCTAssertEqual(attempt.flightTime ?? 0, 0.5, accuracy: 0.0001)
        XCTAssertNil(attempt.contactTime)
    }

    // The legacy screen dropped a landing tagged before the take-off without a
    // word, so the button looked broken. A refusal has to say why.
    func test_tag_refusesAnEventBeforeThePreviousOneAndSaysWhy() {
        var sut = JumpTaggingViewModel(kind: .verticalJump)
        _ = sut.tag(at: 1.75)

        let result = sut.tag(at: 1.25)

        XCTAssertEqual(result, .rejected("The landing has to come after the take-off."))
        XCTAssertEqual(sut.times, [1.75])
    }

    func test_tag_refusesTheFirstFrame() {
        var sut = JumpTaggingViewModel(kind: .verticalJump)

        XCTAssertNotEqual(sut.tag(at: 0), .accepted)
        XCTAssertEqual(sut.times, [])
    }

    // A drop jump has two landings. Naming them by position is what tells the
    // athlete which one the button will mark.
    func test_prompt_namesADropJumpsTagsByPosition() {
        var sut = JumpTaggingViewModel(kind: .dropJump)

        XCTAssertEqual(sut.prompt, "Tag box landing (1 of 3)")
        _ = sut.tag(at: 1.0)
        XCTAssertEqual(sut.prompt, "Tag take-off (2 of 3)")
        _ = sut.tag(at: 1.2)
        XCTAssertEqual(sut.prompt, "Tag landing (3 of 3)")
    }

    func test_attempt_deliversADropJumpsContactAndRSI() throws {
        var sut = JumpTaggingViewModel(kind: .dropJump)
        _ = sut.tag(at: 1.0)
        _ = sut.tag(at: 1.25)
        _ = sut.tag(at: 1.75)

        let attempt = try XCTUnwrap(sut.attempt)
        XCTAssertEqual(attempt.contactTime ?? 0, 0.25, accuracy: 0.0001)
        XCTAssertEqual(attempt.height, 30.66, accuracy: 0.0001)
        XCTAssertEqual(attempt.reactiveStrengthIndex ?? 0, 0.3066 / 0.25, accuracy: 0.0001)
    }

    func test_undo_removesTheLastTag() {
        var sut = JumpTaggingViewModel(kind: .verticalJump)
        _ = sut.tag(at: 1.25)
        _ = sut.tag(at: 1.75)

        sut.undo()

        XCTAssertEqual(sut.times, [1.25])
        XCTAssertEqual(sut.nextEvent, .landing)
    }
}
