//
//  JumpTimingTests.swift
//  PerformanceKitTests
//
//  Created by Findlay Wood on 10/10/2026.
//

import XCTest
@testable import PerformanceKit

final class JumpTimingTests: XCTestCase {

    func test_init_deliversTheFlightOfATakeOffAndLanding() throws {
        let sut = try XCTUnwrap(JumpTiming(plan: [.takeOff, .landing], times: [1.25, 1.75]))

        XCTAssertEqual(sut.flights.count, 1)
        XCTAssertEqual(sut.flights[0], 0.5, accuracy: 0.0001)
        XCTAssertEqual(sut.contacts, [])
    }

    // A drop jump is landing (off the box), take-off, landing. The engine has
    // to read a ground contact as well as a flight from a longer plan, or the
    // later tests need maths of their own.
    func test_init_deliversContactAndFlightOfADropJump() throws {
        let sut = try XCTUnwrap(JumpTiming(plan: [.landing, .takeOff, .landing], times: [1.0, 1.25, 1.75]))

        XCTAssertEqual(sut.contacts.count, 1)
        XCTAssertEqual(sut.contacts[0], 0.25, accuracy: 0.0001)
        XCTAssertEqual(sut.flights.count, 1)
        XCTAssertEqual(sut.flights[0], 0.5, accuracy: 0.0001)
    }

    func test_init_deliversNilUntilEveryEventIsTagged() {
        XCTAssertNil(JumpTiming(plan: [.takeOff, .landing], times: [1.25]))
    }

    func test_init_deliversNilWhenTimesAreOutOfOrder() {
        XCTAssertNil(JumpTiming(plan: [.takeOff, .landing], times: [1.75, 1.25]))
        XCTAssertNil(JumpTiming(plan: [.takeOff, .landing], times: [1.25, 1.25]))
    }

    // Zero means untagged, so the first frame of the video can never be one.
    func test_init_deliversNilWhenTheFirstTagIsAtZero() {
        XCTAssertNil(JumpTiming(plan: [.takeOff, .landing], times: [0, 0.5]))
    }
}
