//
//  SampleProduct.swift
//  InTheGym
//
//  Created by Findlay Wood on 11/10/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//

import Foundation

/// A plan that needs no store, for SwiftUI previews and emulator builds.
///
/// Without it the paywall in the simulator against the emulator was an empty list over a "Not Now"
/// button — nothing to look at and nothing to test. `samples` mirrors the three plans App Store
/// Connect is meant to sell (`StoreKitConfig.storekit`), trial on yearly only, so the screen can
/// be judged as a real user sees it.
/// Buying one succeeds at once; `EmulatorPurchaseManager` is what turns that into pro.
struct SampleProduct: DisplayAndPurchaseProduct {

    let id: String
    let billingPeriod: SubscriptionBillingPeriod?
    let price: Decimal
    let freeTrialDays: Int?

    var displayPrice: String { formattedPrice(price) }

    func formattedPrice(_ amount: Decimal) -> String {
        Self.formatter.string(from: amount as NSDecimalNumber) ?? "\(amount)"
    }

    func purchaseProduct() async throws -> PurchaseProductResult {
        .successVerified(.init(productID: id, purchaseDate: Date(), transactionID: UUID().uuidString))
    }

    static let samples: [SampleProduct] = [
        SampleProduct(id: "sample_weekly", billingPeriod: .week, price: 2.99, freeTrialDays: nil),
        SampleProduct(id: "sample_monthly", billingPeriod: .month, price: 6.99, freeTrialDays: nil),
        SampleProduct(id: "sample_yearly", billingPeriod: .year, price: 59.99, freeTrialDays: 14)
    ]

    private static let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "GBP"
        return formatter
    }()
}
