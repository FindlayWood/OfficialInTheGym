//
//  PurchaseManagerSubscriptionService.swift
//  InTheGym
//
//  Created by Findlay Wood on 03/10/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//
import ProfileKit

/// ProfileKit's view of the subscription, answered by the app's `PurchaseManager`
/// (RevenueCat, or the preview manager in emulator builds).
struct PurchaseManagerSubscriptionService: ProfileSubscriptionService {

    let purchaseManager: PurchaseManager

    var hasUnlockedPro: Bool { purchaseManager.hasUnlockedPro }

    func restorePurchases() async throws {
        try await purchaseManager.restorePurchase()
    }
}
