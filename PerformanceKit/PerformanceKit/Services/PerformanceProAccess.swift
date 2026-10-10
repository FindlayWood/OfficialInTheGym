//
//  PerformanceProAccess.swift
//  PerformanceKit
//
//  Created by Findlay Wood on 10/10/2026.
//
import Foundation

/// Whether the signed-in user has INTHEGYM pro, which every tool requires.
///
/// It is read **each time a tool is opened**, never cached when the router is
/// built. The tab is built once at launch for every user, so a value captured
/// then would keep showing the paywall after the user subscribed, until they
/// relaunched. Buying goes through the app's own paywall, reached by
/// `PerformanceKitRouter.onShowPaywall`.
public protocol PerformanceProAccess {
    var hasUnlockedPro: Bool { get }
}
