//
//  RevenueCatPackageProduct.swift
//  InTheGym
//
//  Created by Findlay Wood on 10/02/2025.
//  Copyright © 2025 FindlayWood. All rights reserved.
//

import Foundation
import RevenueCat

/// A RevenueCat `Package` as the paywall sees it.
///
/// This was an extension on `Package`, which cannot hold anything the package does not — and
/// whether *this user* may take the free trial is not on the package. It is answered by
/// `checkTrialOrIntroDiscountEligibility` when the offering loads and carried here.
struct RevenueCatPackageProduct: DisplayAndPurchaseProduct {

    let package: Package
    let isTrialEligible: Bool

    var id: String { package.storeProduct.productIdentifier }

    var billingPeriod: SubscriptionBillingPeriod? {
        guard let period = package.storeProduct.subscriptionPeriod, period.value == 1 else { return nil }
        switch period.unit {
        case .week: return .week
        case .month: return .month
        case .year: return .year
        default: return nil
        }
    }

    var price: Decimal { package.storeProduct.price }

    var displayPrice: String { package.storeProduct.localizedPriceString }

    var freeTrialDays: Int? {
        guard isTrialEligible,
              let offer = package.storeProduct.introductoryDiscount,
              offer.paymentMode == .freeTrial
        else { return nil }
        let days: Int
        switch offer.subscriptionPeriod.unit {
        case .day: days = offer.subscriptionPeriod.value
        case .week: days = offer.subscriptionPeriod.value * 7
        case .month: days = offer.subscriptionPeriod.value * 30
        case .year: days = offer.subscriptionPeriod.value * 365
        @unknown default: return nil
        }
        return days * offer.numberOfPeriods
    }

    func formattedPrice(_ amount: Decimal) -> String {
        package.storeProduct.priceFormatter?.string(from: amount as NSDecimalNumber) ?? "\(amount)"
    }

    func purchaseProduct() async throws -> PurchaseProductResult {
        let (transaction, _, userCancelled) = try await Purchases.shared.purchase(package: package)
        if userCancelled {
            return .userCancelled
        } else if let transaction {
            return .successVerified(.init(productID: transaction.productIdentifier, purchaseDate: transaction.purchaseDate, transactionID: transaction.id))
        } else {
            return .failed
        }
    }
}
