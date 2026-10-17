//
//  ProPlan.swift
//  InTheGym
//
//  Created by Findlay Wood on 11/10/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//

import Foundation

/// One plan on the paywall: a product the store sold us, and the comparisons drawn from it.
///
/// **Yearly is the recommended plan** — preselected, badged, carrying the free trial, and the only
/// plan that states a saving. Monthly was recommended first; yearly replaced it because annual
/// subscribers stay longer and are worth more, which is why most subscription apps lead with it.
///
/// Every claim is worked out from the store's own prices, never typed in, so a price change in App
/// Store Connect cannot leave the paywall claiming something no longer true:
/// - the saving compares against the next-shorter plan (yearly against monthly — the plan a user
///   would otherwise pick), rounded down;
/// - the badge reads "Best value" only while the plan really is the cheapest per week, and falls back
///   to "Recommended" if prices ever make that false (`badgeTitle(among:)`).
struct ProPlan: Identifiable {

    static let recommendedPeriod: SubscriptionBillingPeriod = .year

    let product: DisplayAndPurchaseProduct
    let period: SubscriptionBillingPeriod

    var id: String { product.id }
    var isRecommended: Bool { period == Self.recommendedPeriod }
    var freeTrialDays: Int? { product.freeTrialDays }

    /// "£5.99 / month"
    var priceText: String { "\(product.displayPrice) / \(period.unit)" }

    /// What a longer plan works out at in a shorter unit — "£1.38 / week" for monthly, "£5.00 / month"
    /// for yearly. Weekly has none; it is the unit.
    var equivalentText: String? {
        switch period {
        case .week:
            return nil
        case .month:
            return "\(product.formattedPrice(product.price / period.weeks)) / week"
        case .year:
            return "\(product.formattedPrice(product.price / 12)) / month"
        }
    }

    /// The whole-percent saving per week against `other`, or `nil` when there is none worth saying
    /// (under 5%). Rounded **down**, so the screen never claims more than the prices give.
    func savingsPercent(against other: ProPlan) -> Int? {
        let mine = product.price / period.weeks
        let theirs = other.product.price / other.period.weeks
        guard theirs > 0, mine < theirs else { return nil }
        var fraction = (1 - mine / theirs) * 100
        var floored = Decimal()
        NSDecimalRound(&floored, &fraction, 0, .down)
        let percent = NSDecimalNumber(decimal: floored).intValue
        return percent >= 5 ? percent : nil
    }

    /// "BEST VALUE" while this plan is the cheapest per week of `plans`, "RECOMMENDED" otherwise.
    func badgeTitle(among plans: [ProPlan]) -> String {
        let mine = product.price / period.weeks
        let isCheapest = plans.allSatisfy { $0.id == id || mine <= $0.product.price / $0.period.weeks }
        return isCheapest ? "BEST VALUE" : "RECOMMENDED"
    }

    /// The products the store returned, as plans: one per period, shortest first, anything the
    /// paywall cannot name left out.
    static func plans(from products: [DisplayAndPurchaseProduct]) -> [ProPlan] {
        var byPeriod: [SubscriptionBillingPeriod: ProPlan] = [:]
        for product in products {
            guard let period = product.billingPeriod, byPeriod[period] == nil else { continue }
            byPeriod[period] = ProPlan(product: product, period: period)
        }
        return byPeriod.values.sorted { $0.period < $1.period }
    }
}
