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

    init(timing: JumpTiming) {
        let flight = timing.flights.last ?? 0
        self.init(
            height: JumpPhysics.heightCentimetres(flightTime: flight),
            flightTime: flight,
            contactTime: timing.contacts.last
        )
    }
}
