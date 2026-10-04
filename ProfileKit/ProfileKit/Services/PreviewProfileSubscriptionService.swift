//
//  PreviewProfileSubscriptionService.swift
//  ProfileKit
//
//  Created by Findlay Wood on 03/10/2026.
//
import Foundation

/// Preview conformer with a fixed subscription state.
public final class PreviewProfileSubscriptionService: ProfileSubscriptionService, @unchecked Sendable {

    public let hasUnlockedPro: Bool

    public init(hasUnlockedPro: Bool = false) {
        self.hasUnlockedPro = hasUnlockedPro
    }

    public func restorePurchases() async throws {}
}
