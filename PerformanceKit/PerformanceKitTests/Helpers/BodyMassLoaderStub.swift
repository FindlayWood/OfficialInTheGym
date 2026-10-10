//
//  BodyMassLoaderStub.swift
//  PerformanceKitTests
//
//  Created by Findlay Wood on 10/10/2026.
//
import Foundation
@testable import PerformanceKit

/// A fixed body mass, or none. Never asserts.
final class BodyMassLoaderStub: BodyMassLoader, @unchecked Sendable {

    var bodyMass: Double?

    init(bodyMass: Double? = nil) {
        self.bodyMass = bodyMass
    }

    func loadBodyMass() async throws -> Double? {
        bodyMass
    }
}
