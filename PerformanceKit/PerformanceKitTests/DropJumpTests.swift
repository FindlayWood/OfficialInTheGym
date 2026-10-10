//
//  DropJumpTests.swift
//  PerformanceKitTests
//
//  Created by Findlay Wood on 10/10/2026.
//

import XCTest
@testable import PerformanceKit

final class DropJumpTests: XCTestCase {

    // RSI = height (m) / contact (s): 0.40 m off 0.20 s is 2.0.
    func test_reactiveStrengthIndex_deliversHeightInMetresOverContact() {
        let sut = JumpAttempt(height: 40, flightTime: nil, contactTime: 0.20)

        XCTAssertEqual(sut.reactiveStrengthIndex ?? 0, 2.0, accuracy: 0.0001)
    }

    func test_reactiveStrengthIndex_deliversNilWithoutAContact() {
        XCTAssertNil(JumpAttempt(height: 40, flightTime: 0.5, contactTime: nil).reactiveStrengthIndex)
    }

    // A drop jump's best is its best RSI, not its highest jump. A high rebound
    // off a slow, long contact is the opposite of what the test rewards.
    func test_best_deliversTheHighestRSINotTheHighestJump() {
        let tallButSlow = JumpAttempt(height: 44, flightTime: nil, contactTime: 0.40)
        let quick = JumpAttempt(height: 36, flightTime: nil, contactTime: 0.18)
        let sut = JumpTestSession(id: "a", kind: .dropJump, date: .fixed, attempts: [tallButSlow, quick], boxHeight: 30)

        XCTAssertEqual(sut.best, quick)
    }

    func test_headlineText_deliversRSIForADropJumpAndHeightOtherwise() {
        let attempt = JumpAttempt(height: 36, flightTime: nil, contactTime: 0.18)

        XCTAssertEqual(JumpTestKind.dropJump.headlineText(of: attempt), "RSI 2.00")
        XCTAssertEqual(JumpTestKind.cmj.headlineText(of: attempt), "36.0 cm")
    }

    func test_tagPlanTitlesAndHints_lineUpForEveryTest() {
        for kind in JumpTestKind.allCases {
            XCTAssertEqual(kind.tagTitles.count, kind.tagPlan.count, "\(kind)")
            XCTAssertEqual(kind.tagHints.count, kind.tagPlan.count, "\(kind)")
            XCTAssertEqual(kind.tagSteps.count, kind.tagPlan.count, "\(kind)")
        }
    }

    // The simulator's sample jump goes through the same timing and physics as
    // a recording. A sample that skipped them could hide a broken pipeline.
    func test_sample_deliversAMeasuredAttemptForEveryTest() {
        for kind in JumpTestKind.allCases {
            let sut = JumpCameraUnavailableScreen.sample(for: kind)

            XCTAssertGreaterThan(sut.height, 25, "\(kind)")
            XCTAssertEqual(sut.contactTime != nil, kind == .dropJump, "\(kind)")
        }
    }

    @MainActor
    func test_save_storesTheBoxHeightForADropJumpOnly() async {
        let spy = JumpTestServicesSpy()
        let drop = JumpTestSessionViewModel(kind: .dropJump, writer: spy, bodyMassLoader: BodyMassLoaderStub(), now: { .fixed }, makeId: { "d" })
        drop.boxHeight = 40
        drop.add(JumpAttempt(height: 36, flightTime: nil, contactTime: 0.2))
        let cmj = JumpTestSessionViewModel(kind: .cmj, writer: spy, bodyMassLoader: BodyMassLoaderStub(), now: { .fixed }, makeId: { "c" })
        cmj.add(JumpAttempt(height: 40, flightTime: nil, contactTime: nil))

        await drop.save()
        await cmj.save()

        let boxes = spy.receivedMessages.compactMap { message -> Double?? in
            if case .write(let session) = message { return .some(session.boxHeight) }
            return nil
        }
        XCTAssertEqual(boxes, [40, nil])
    }
}
