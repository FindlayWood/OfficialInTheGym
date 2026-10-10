//
//  PerformanceProAccess.swift
//  PerformanceKit
//
//  Created by Findlay Wood on 10/10/2026.
//
import Foundation

/// Whether the signed-in user has INTHEGYM pro, which the whole PERFORMANCE
/// tab requires.
///
/// It is read **every time the tab appears**, never cached when the router is
/// built. The tab is built once at launch for every user, so a value captured
/// then would keep a new subscriber locked out until they relaunched. Buying
/// goes through the app's own paywall, reached by
/// `PerformanceKitRouter.onShowPaywall`.
public protocol PerformanceProAccess {
    var hasUnlockedPro: Bool { get }
}
