//
//  PurchaseManagerStub.swift
//  InTheGymTests
//
//  Created by Findlay Wood on 12/10/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//

import Combine
import Foundation
@testable import InTheGym

/// Sells `SampleProduct.samples` — weekly, monthly, and yearly with a 14-day trial — and every
/// purchase succeeds. Never asserts.
final class PurchaseManagerStub: PurchaseManager, ObservableObject {

    @Published private(set) var products: [PurchaseableProduct] = []
    var productsPublished: Published<[PurchaseableProduct]> { _products }
    var productsPublisher: Published<[PurchaseableProduct]>.Publisher { $products }

    var hasUnlockedPro = false

    func loadProducts() async throws -> [DisplayAndPurchaseProduct] {
        SampleProduct.samples
    }

    func purchase(_ product: PurchaseableProduct) async throws -> PurchaseProductResult {
        try await product.purchaseProduct()
    }

    func restorePurchase() async throws {}
}
