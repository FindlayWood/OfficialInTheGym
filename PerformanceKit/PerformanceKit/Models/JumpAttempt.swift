//
//  JumpAttempt.swift
//  PerformanceKit
//
//  Created by Findlay Wood on 10/10/2026.
//
import Foundation

/// One measured jump. `height` is centimetres, from the attempt's last flight.
/// `contactTime` is the last ground contact before it, nil for a test with
/// none (a vertical jump starts on the ground). Times are seconds, nil for
/// jumps saved before the engine, which stored a height only.
public struct JumpAttempt: Equatable, Sendable {
    public let height: Double
    public let flightTime: Double?
    public let contactTime: Double?

    public init(height: Double, flightTime: Double?, contactTime: Double?) {
        self.height = height
        self.flightTime = flightTime
        self.contactTime = contactTime
    }

    /// Reactive strength index: jump height in metres over ground contact time
    /// in seconds, the usual field form. Nil without a contact, which only a
    /// test that lands before it jumps has. Around 1.5 is moderate and above
    /// 2.5 is very reactive for a trained athlete.
    public var reactiveStrengthIndex: Double? {
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

    init(timing: JumpTiming) {
        let flight = timing.flights.last ?? 0
        self.init(
            height: JumpPhysics.heightCentimetres(flightTime: flight),
            flightTime: flight,
            contactTime: timing.contacts.last
        )
    }
}
