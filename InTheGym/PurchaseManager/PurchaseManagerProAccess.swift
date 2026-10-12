//
//  PurchaseManagerProAccess.swift
//  InTheGym
//
//  Created by Findlay Wood on 12/10/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//

import DiscoverKit
import MyDayKit
import PerformanceKit
import StatsKit

/// Every framework's pro check, answered by the app's one `PurchaseManager`.
///
/// Each framework declares its own `…ProAccess` protocol, because none of them may import the app
/// or each other — but what they ask is one question, so **one adapter answers all of them**. Four
/// adapters each forwarding `hasUnlockedPro` would be four places for "who has pro" to drift, which
/// is exactly what the coach-granted passes will change. It forwards on every read rather than
/// copying the flag, because every gate relies on reading it fresh.
///
/// It replaced `PurchaseManagerPerformanceProAccess`. ProfileKit's `PurchaseManagerSubscriptionService`
/// is separate: it restores and manages subscriptions, not just reads them.
final class PurchaseManagerProAccess {

    // MARK: - Properties
    private let purchaseManager: PurchaseManager

    // MARK: - Initializer
    init(purchaseManager: PurchaseManager) {
        self.purchaseManager = purchaseManager
    }

    var hasUnlockedPro: Bool { purchaseManager.hasUnlockedPro }
}

extension PurchaseManagerProAccess: PerformanceProAccess, StatsProAccess, MyDayProAccess, DiscoverProAccess {}
