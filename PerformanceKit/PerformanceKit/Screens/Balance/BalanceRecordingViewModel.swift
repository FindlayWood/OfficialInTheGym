//
//  BalanceRecordingViewModel.swift
//  PerformanceKit
//
//  Created by Findlay Wood on 10/10/2026.
//
import Combine
import Foundation

/// One single-leg stand: ready, a five-second countdown, thirty seconds of
/// motion sampling, then the result to keep or redo.
///
/// - **"Foot down" ends a stand early** and keeps what was held, marked
///   incomplete (`BalanceAttempt.completed`). During the countdown it calls
///   the stand off instead.
/// - **Time is counted in ticks, not added up as decimals**, so thirty seconds
///   of 0.1 s ticks is exactly thirty, never 29.999 or 30.1.
/// - Waiting, the sensors and the cues are injected, so a test runs a whole
///   stand instantly.
@MainActor
final class BalanceRecordingViewModel: ObservableObject {

    enum Phase: Equatable {
        case ready
        case countdown(Int)
        case recording(elapsed: Double)
        case finished(BalanceAttempt)
        case unavailable
    }

    static let countdownSeconds = 5
    static let tick = 0.1

    @Published private(set) var phase: Phase
    let side: JumpSide

    var onKeep: ((BalanceAttempt) -> Void)?
    var onCancel: (() -> Void)?

    private let source: MotionSampleSource
    private let pause: (Double) async -> Void
    private let cue: @MainActor (BalanceCue) -> Void
    private var samples: [MotionSample] = []
    private var stopRequested = false
    private var task: Task<Void, Never>?

    init(
        side: JumpSide,
        source: MotionSampleSource,
        pause: @escaping (Double) async -> Void = { try? await Task.sleep(for: .seconds($0)) },
        cue: @escaping @MainActor (BalanceCue) -> Void = { BalanceCue.play($0) }
    ) {
        self.side = side
        self.source = source
        self.pause = pause
        self.cue = cue
        self.phase = source.isAvailable ? .ready : .unavailable
    }

    var totalTicks: Int {
        Int((BalanceAttempt.targetDuration / Self.tick).rounded())
    }

    func start() {
        guard phase == .ready else { return }
        stopRequested = false
        task = Task { await run() }
    }

    /// Runs the whole stand. Exposed for tests, which await it directly.
    func run() async {
        for remaining in stride(from: Self.countdownSeconds, to: 0, by: -1) {
            phase = .countdown(remaining)
            cue(.countdown)
            await pause(1)
            if stopRequested {
                phase = .ready
                return
            }
        }

        samples = []
        cue(.start)
        source.start { [weak self] in self?.samples.append($0) }
        var ticks = 0
        phase = .recording(elapsed: 0)
        while ticks < totalTicks && !stopRequested {
            await pause(Self.tick)
            ticks += 1
            phase = .recording(elapsed: Double(ticks) * Self.tick)
        }
        source.stop()
        cue(.end)
        phase = .finished(BalanceAttempt(
            sway: BalanceSway.milliG(from: samples),
            duration: Double(ticks) * Self.tick,
            side: side
        ))
    }

    func footDown() {
        stopRequested = true
    }

    func retry() {
        guard case .finished = phase else { return }
        phase = source.isAvailable ? .ready : .unavailable
    }

    func keep() {
        guard case .finished(let attempt) = phase else { return }
        onKeep?(attempt)
    }

    func cancel() {
        stopRequested = true
        task?.cancel()
        source.stop()
        onCancel?()
    }

    /// A plausible full stand, for the simulator, which has no sensors.
    func addSample() {
        let attempt = BalanceAttempt(sway: Double.random(in: 8...25).rounded(toPlaces: 1), duration: BalanceAttempt.targetDuration, side: side)
        phase = .finished(attempt)
    }
}
