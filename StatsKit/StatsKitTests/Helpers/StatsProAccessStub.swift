//
//  StatsProAccessStub.swift
//  StatsKitTests
//
//  Created by Findlay Wood on 12/10/2026.
//

import Foundation
@testable import StatsKit

/// A settable pro flag. Settable rather than fixed so a test can subscribe between two appearances
/// of the tab, the case the gate reads it fresh for. Never asserts.
final class StatsProAccessStub: StatsProAccess, @unchecked Sendable {

    var hasUnlockedPro: Bool

    init(hasUnlockedPro: Bool) {
        self.hasUnlockedPro = hasUnlockedPro
    }
}
