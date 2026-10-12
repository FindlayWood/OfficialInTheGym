//
//  StatsProAccess.swift
//  StatsKit
//
//  Created by Findlay Wood on 12/10/2026.
//

import Foundation

/// Whether the signed-in user has INTHEGYM pro, which the whole STATS tab requires.
///
/// The same contract as PerformanceKit's `PerformanceProAccess`, and answered by the same object
/// in the app: read **every time the tab appears**, never captured when the router is built. The
/// tab is built once at launch, so a value read then would keep a new subscriber locked out until
/// they relaunched. Buying goes through the app's paywall, reached by `StatsKitRouter.onShowPaywall`.
public protocol StatsProAccess {
    var hasUnlockedPro: Bool { get }
}
