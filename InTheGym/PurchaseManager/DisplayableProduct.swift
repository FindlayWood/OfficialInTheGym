//
//  DisplayableProduct.swift
//  InTheGym
//
//  Created by Findlay Wood on 10/02/2025.
//  Copyright © 2025 FindlayWood. All rights reserved.
//

import Foundation

/// What the paywall needs to draw a plan.
///
/// **`freeTrialDays` is `nil` unless this user can actually get the trial.** Apple gives one
/// introductory offer per subscription group, ever, so someone who trialled last year is charged on
/// day one. A paywall that promised them "14 days free" anyway would be a false price claim — the
/// button would say "Start free trial" and bill them. Eligibility is checked when the products load,
/// not assumed from the product having an offer.
protocol DisplayableProduct: PurchaseableProduct {
    var id: String { get }
    var billingPeriod: SubscriptionBillingPeriod? { get }
    var price: Decimal { get }
    var displayPrice: String { get }
    var freeTrialDays: Int? { get }
    /// Formats any amount in this product's currency and locale — for per-week and per-month
    /// equivalents, which are not prices the store hands us.
    func formattedPrice(_ amount: Decimal) -> String
}
