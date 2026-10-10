//
//  JumpAttempt.swift
//  PerformanceKit
//
//  Created by Findlay Wood on 10/10/2026.
//
import Foundation

/// One measured jump. `height` is centimetres and times are seconds; times are
/// nil for jumps saved before the engine, which stored a height only.
///
/// For most tests the attempt is its last flight (and, for a drop jump, the
/// ground contact before it). **Repeated jumps are different**: ten hops make
/// one attempt, and its figures are the **mean of the best five rebounds by
/// RSI**, the 10/5 test, with that RSI stored (`storedReactiveStrength`)
/// because a mean of ratios is not the ratio of the means.
///
/// `side` is the leg, for a single-leg test.
public struct JumpAttempt: Equatable, Sendable {
    public let height: Double
    public let flightTime: Double?
    public let contactTime: Double?
    public let side: JumpSide?
    public let storedReactiveStrength: Double?

    public init(height: Double, flightTime: Double?, contactTime: Double?, side: JumpSide? = nil, reactiveStrength: Double? = nil) {
        self.height = height
        self.flightTime = flightTime
        self.contactTime = contactTime
        self.side = side
        self.storedReactiveStrength = reactiveStrength
    }

    /// Reactive strength index: jump height in metres over ground contact time
    /// in seconds, the usual field form, or the stored 10/5 figure for
    /// repeated jumps. Nil without a contact, which only a test that lands
    /// before it jumps has. Around 1.5 is moderate and above 2.5 is very
    /// reactive for a trained athlete.
    public var reactiveStrengthIndex: Double? {
        if let storedReactiveStrength { return storedReactiveStrength }
        guard let contactTime, contactTime > 0 else { return nil }
        return (height / 100) / contactTime
    }

    /// The number a test's best attempt is chosen by.
    func score(for kind: JumpTestKind) -> Double {
        switch kind.headline {
        case .height: height
        case .reactiveStrength: reactiveStrengthIndex ?? 0
        }
    }

    /// This attempt on `side`.
    func on(_ side: JumpSide) -> JumpAttempt {
        JumpAttempt(height: height, flightTime: flightTime, contactTime: contactTime, side: side, reactiveStrength: storedReactiveStrength)
    }

    init(timing: JumpTiming, kind: JumpTestKind) {
        switch kind {
        case .repeatedJumps:
            self = Self.tenFive(timing: timing, best: kind.bestHops)
        case .cmj, .verticalJump, .dropJump, .singleLegCMJ:
            let flight = timing.flights.last ?? 0
            self.init(height: JumpPhysics.heightCentimetres(flightTime: flight), flightTime: flight, contactTime: timing.contacts.last)
        }
    }

    /// Each rebound is a ground contact and the flight after it. The best
    /// `best` by RSI are averaged.
    private static func tenFive(timing: JumpTiming, best: Int) -> JumpAttempt {
        let rebounds: [(contact: Double, flight: Double)] = timing.contacts.enumerated().compactMap { index, contact in
            let flightIndex = index + 1
            guard flightIndex < timing.flights.count, contact > 0 else { return nil }
            return (contact, timing.flights[flightIndex])
        }
        let ranked = rebounds
            .map { (contact: $0.contact, flight: $0.flight, rsi: JumpPhysics.heightCentimetres(flightTime: $0.flight) / 100 / $0.contact) }
            .sorted { $0.rsi > $1.rsi }
            .prefix(best)
        guard !ranked.isEmpty else {
            let flight = timing.flights.last ?? 0
            return JumpAttempt(height: JumpPhysics.heightCentimetres(flightTime: flight), flightTime: flight, contactTime: nil)
        }
        let count = Double(ranked.count)
        let flight = ranked.map(\.flight).reduce(0, +) / count
        return JumpAttempt(
            height: (ranked.map { JumpPhysics.heightCentimetres(flightTime: $0.flight) }.reduce(0, +) / count).rounded(toPlaces: 2),
            flightTime: flight,
            contactTime: ranked.map(\.contact).reduce(0, +) / count,
            reactiveStrength: ranked.map(\.rsi).reduce(0, +) / count
        )
    }
}
