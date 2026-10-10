//
//  PerformanceProAccessStub.swift
//  PerformanceKitTests
//
//  Created by Findlay Wood on 10/10/2026.
//
import Foundation
@testable import PerformanceKit

/// A settable pro flag. Settable rather than fixed so a test can subscribe
/// between two taps, the case the router reads it fresh for. Never asserts.
final class PerformanceProAccessStub: PerformanceProAccess, @unchecked Sendable {

    var hasUnlockedPro: Bool

    init(hasUnlockedPro: Bool) {
        self.hasUnlockedPro = hasUnlockedPro
    }
}
