//
//  PurchaseManagerPerformanceProAccess.swift
//  InTheGym
//
//  Created by Findlay Wood on 10/10/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//
import PerformanceKit

/// PerformanceKit's pro check, answered by the app's `PurchaseManager`. It
/// forwards on every read rather than copying the flag, because the router
/// relies on reading it fresh each time a tool is opened.
final class PurchaseManagerPerformanceProAccess: PerformanceProAccess {

    // MARK: - Properties
    private let purchaseManager: PurchaseManager

    // MARK: - Initializer
    init(purchaseManager: PurchaseManager) {
        self.purchaseManager = purchaseManager
    }

    var hasUnlockedPro: Bool { purchaseManager.hasUnlockedPro }
}
