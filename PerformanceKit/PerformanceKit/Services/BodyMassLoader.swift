//
//  BodyMassLoader.swift
//  PerformanceKit
//
//  Created by Findlay Wood on 10/10/2026.
//
import Foundation

/// The athlete's latest body weight in kilograms, or nil if they have never
/// logged one. Read when a test starts, so power is worked out with the weight
/// they are now.
public protocol BodyMassLoader {
    func loadBodyMass() async throws -> Double?
}
