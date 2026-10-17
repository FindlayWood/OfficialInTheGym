//
//  PreviewStatsProAccess.swift
//  StatsKit
//
//  Created by Findlay Wood on 12/10/2026.
//

import Foundation

/// A fixed pro flag for SwiftUI previews. Ships in the framework, as the other `Preview…` and
/// `Mock…` conformers do.
public final class PreviewStatsProAccess: StatsProAccess, @unchecked Sendable {

    public var hasUnlockedPro: Bool

    public init(hasUnlockedPro: Bool) {
        self.hasUnlockedPro = hasUnlockedPro
    }
}
