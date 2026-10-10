//
//  JumpPhysics.swift
//  PerformanceKit
//
//  Created by Findlay Wood on 10/10/2026.
//
import Foundation

/// **The one definition of jump height from flight time**, used by every jump
/// test: h = t² × g / 8, with g / 8 = 1.22625 (9.81 / 8). A body in the air for
/// t seconds rises for t / 2 of them, and h = ½g(t/2)². In metres; returned in
/// centimetres to two places, as the legacy calculation always was.
enum JumpPhysics {

    static let constant = 1.22625

    static func heightCentimetres(flightTime: Double) -> Double {
        let metres = flightTime * flightTime * constant
        return (metres * 100).rounded(toPlaces: 2)
    }
}
