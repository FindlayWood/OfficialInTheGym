//
//  ProfileSubscriptionService.swift
//  ProfileKit
//
//  Created by Findlay Wood on 03/10/2026.
//
import Foundation

/// The signed-in user's INTHEGYM pro subscription, as the settings screen needs
/// it: whether it is active, and a way to restore it on a new device.
///
/// It is narrow on purpose. Buying goes through the app's existing paywall,
/// reached by `ProfileKitRouter.onShowPaywall`, rather than a second purchase
/// flow built here.
public protocol ProfileSubscriptionService {
    var hasUnlockedPro: Bool { get }
    func restorePurchases() async throws
}
