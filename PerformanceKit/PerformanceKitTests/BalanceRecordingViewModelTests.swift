//
//  BalanceRecordingViewModelTests.swift
//  PerformanceKitTests
//
//  Created by Findlay Wood on 10/10/2026.
//

import XCTest
@testable import PerformanceKit

@MainActor
final class BalanceRecordingViewModelTests: XCTestCase {

    func test_init_deliversUnavailableWithoutSensors() {
        let sut = makeSUT(source: MotionSampleSourceStub(isAvailable: false))

        XCTAssertEqual(sut.phase, .unavailable)
    }

    // A full stand is exactly thirty seconds. Adding up 0.1 s steps as
    // decimals drifts to 29.999 or 30.1, which could mark a full stand short.
    func test_run_deliversAFullStandWithItsSway() async throws {
        let source = MotionSampleSourceStub(samples: (0..<50).map { _ in MotionSample(gravity: [0, -1, 0], acceleration: [0.01, 0, 0]) })
        let sut = makeSUT(source: source)

        await sut.run()

        guard case .finished(let attempt) = sut.phase else { return XCTFail("Expected a result, got \(sut.phase)") }
        XCTAssertEqual(attempt.duration, 30, accuracy: 0.0001)
        XCTAssertTrue(attempt.completed)
        XCTAssertEqual(attempt.sway, 10, accuracy: 0.0001)
        XCTAssertEqual(attempt.side, .right)
        XCTAssertEqual(source.stopCount, 1)
    }

    func test_run_playsTheCountdownThenStartAndEnd() async {
        var cues: [BalanceCue] = []
        let sut = BalanceRecordingViewModel(side: .left, source: MotionSampleSourceStub(), pause: { _ in }, cue: { cues.append($0) })

        await sut.run()

        XCTAssertEqual(cues, [.countdown, .countdown, .countdown, .countdown, .countdown, .start, .end])
    }

    func test_footDown_endsTheStandEarlyAndMarksItIncomplete() async {
        var ticks = 0
        var sut: BalanceRecordingViewModel!
        sut = BalanceRecordingViewModel(side: .left, source: MotionSampleSourceStub(), pause: { seconds in
            // Foot down twelve seconds into the stand.
            if seconds < 1 {
                ticks += 1
                if ticks == 120 { sut.footDown() }
            }
        }, cue: { _ in })

        await sut.run()

        guard case .finished(let attempt) = sut.phase else { return XCTFail("Expected a result") }
        XCTAssertEqual(attempt.duration, 12, accuracy: 0.0001)
        XCTAssertFalse(attempt.completed)
    }

    // Foot down during the countdown calls the stand off. Recording a stand
    // that never started would leave a zero-sway "result" to keep.
    func test_footDown_duringTheCountdownCallsTheStandOff() async {
        let source = MotionSampleSourceStub()
        var sut: BalanceRecordingViewModel!
        sut = BalanceRecordingViewModel(side: .left, source: source, pause: { _ in sut.footDown() }, cue: { _ in })

        await sut.run()

        XCTAssertEqual(sut.phase, .ready)
        XCTAssertEqual(source.startCount, 0)
    }

    func test_keep_handsTheResultOn() async {
        let sut = makeSUT(source: MotionSampleSourceStub())
        var kept: [BalanceAttempt] = []
        sut.onKeep = { kept.append($0) }
        await sut.run()

        sut.keep()

        XCTAssertEqual(kept.count, 1)
    }

    // MARK: - Helpers

    private func makeSUT(source: MotionSampleSourceStub) -> BalanceRecordingViewModel {
        BalanceRecordingViewModel(side: .right, source: source, pause: { _ in }, cue: { _ in })
    }
}
