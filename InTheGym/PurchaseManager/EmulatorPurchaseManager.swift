//
//  EmulatorPurchaseManager.swift
//  InTheGym
//
//  Created by Findlay Wood on 11/10/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//

import Combine
import Foundation

#if EMULATOR
/// The purchase manager for emulator builds, where nothing can be bought — and **the one switch
/// that unlocks pro everywhere**: STATS, PERFORMANCE, clips, stamps and settings all read
/// `hasUnlockedPro` off this one instance, which `SceneDelegate` hands to every flow.
///
/// It replaced `PreviewPurchaseManager` here, which loaded no plans and answered `false` for ever,
/// and `EmulatorUnlockPerformanceProAccess`, which unlocked only PERFORMANCE — so testing anything
/// else behind pro was impossible. Both "Unlock for testing" buttons (the paywall's and the
/// PERFORMANCE locked screen's) and buying any sample plan land on `unlockForTesting()`.
///
/// **Compiled only with `-D EMULATOR`** (the InTheGym-EM scheme), which also points Firebase at
/// localhost, so a build that has it cannot talk to production. In memory only: a relaunch is
/// locked again, which is what lets the paywall be tested more than once.
final class EmulatorPurchaseManager: PurchaseManager, ObservableObject {

    // MARK: - Properties
    @Published private(set) var products: [PurchaseableProduct] = []
    var productsPublished: Published<[PurchaseableProduct]> { _products }
    var productsPublisher: Published<[PurchaseableProduct]>.Publisher { $products }

    private(set) var hasUnlockedPro = false

    func unlockForTesting() {
        hasUnlockedPro = true
    }

    // MARK: - PurchaseManager
    func loadProducts() async throws -> [DisplayAndPurchaseProduct] {
        SampleProduct.samples
    }

    func purchase(_ product: PurchaseableProduct) async throws -> PurchaseProductResult {
        let result = try await product.purchaseProduct()
        if case .successVerified = result {
            unlockForTesting()
        }
        return result
    }

    func restorePurchase() async throws {}
}
#endif
