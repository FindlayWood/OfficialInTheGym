//
//  RepeatedJumpsTests.swift
//  PerformanceKitTests
//
//  Created by Findlay Wood on 10/10/2026.
//

import XCTest
@testable import PerformanceKit

final class RepeatedJumpsTests: XCTestCase {

    func test_tagPlan_isTenHopsOfTakeOffAndLanding() {
        let plan = JumpTestKind.repeatedJumps.tagPlan

        XCTAssertEqual(plan.count, 20)
        XCTAssertEqual(plan.first, .takeOff)
        XCTAssertEqual(plan.last, .landing)
        XCTAssertEqual(plan.filter { $0 == .takeOff }.count, 10)
    }

    // Twenty tags in a row are only workable if each says which hop it is.
    func test_tagTitles_numberEachHop() {
        let titles = JumpTestKind.repeatedJumps.tagTitles

        XCTAssertEqual(Array(titles.prefix(4)), ["take-off 1", "landing 1", "take-off 2", "landing 2"])
        XCTAssertEqual(titles.last, "landing 10")
    }

    // 10/5: each rebound's RSI is its flight's height over the contact before
    // it, and the result is the mean of the best five. Averaging all nine, or
    // taking the single best, would both read differently.
    func test_attempt_deliversTheMeanOfTheBestFiveRebounds() throws {
        // Nine rebounds, all 0.5 s flights (30.66 cm); contacts get slower.
        let contacts = [0.15, 0.16, 0.17, 0.18, 0.19, 0.30, 0.31, 0.32, 0.33]
        let times = Self.times(firstFlight: 0.5, contacts: contacts, flight: 0.5)

        let timing = try XCTUnwrap(JumpTiming(plan: JumpTestKind.repeatedJumps.tagPlan, times: times))
        let sut = JumpAttempt(timing: timing, kind: .repeatedJumps)

        let expected = [0.15, 0.16, 0.17, 0.18, 0.19].map { 0.3066 / $0 }.reduce(0, +) / 5
        XCTAssertEqual(sut.reactiveStrengthIndex ?? 0, expected, accuracy: 0.0001)
        XCTAssertEqual(sut.contactTime ?? 0, 0.17, accuracy: 0.0001)
        XCTAssertEqual(sut.height, 30.66, accuracy: 0.0001)
    }

    func test_best_deliversTheAttemptWithTheBetterTenFiveRSI() {
        let better = JumpAttempt(height: 30, flightTime: nil, contactTime: 0.2, reactiveStrength: 2.1)
        let worse = JumpAttempt(height: 34, flightTime: nil, contactTime: 0.2, reactiveStrength: 1.6)
        let sut = JumpTestSession(id: "a", kind: .repeatedJumps, date: .fixed, attempts: [worse, better])

        XCTAssertEqual(sut.best, better)
    }

    // MARK: - Helpers

    /// Tag times for a run of hops: take-off at 1.0, then each flight and
    /// contact in turn.
    private static func times(firstFlight: Double, contacts: [Double], flight: Double) -> [Double] {
        var times = [1.0]
        var time = 1.0 + firstFlight
        times.append(time)
        for contact in contacts {
            time += contact
            times.append(time)
            time += flight
            times.append(time)
        }
        return times
    }
}
