//
//  SubscriptionBillingPeriod.swift
//  InTheGym
//
//  Created by Findlay Wood on 11/10/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//

import Foundation

/// How often a pro plan bills. Only the three the paywall sells.
///
/// It replaced two string properties, `period` and `perPeriod`, which the RevenueCat extension
/// filled from identical `switch`es (both spelling week "weel") and the StoreKit extension filled
/// from a third, which `fatalError`ed on any month count it had not listed. A plan the paywall
/// cannot name is now `nil` and left off the screen rather than crashing it.
enum SubscriptionBillingPeriod: Int, CaseIterable, Comparable {
    case week
    case month
    case year

    /// "Weekly", "Monthly", "Yearly" — the card title.
    var title: String {
        switch self {
        case .week: "Weekly"
        case .month: "Monthly"
        case .year: "Yearly"
        }
    }

    /// "week", "month", "year" — after a price, as in "£5.99 / month".
    var unit: String {
        switch self {
        case .week: "week"
        case .month: "month"
        case .year: "year"
        }
    }

    /// Weeks in one billing period, for comparing plans on one scale. A month is 52 / 12 weeks,
    /// not four — four would overstate the monthly plan's saving against the weekly one.
    var weeks: Decimal {
        switch self {
        case .week: 1
        case .month: Decimal(52) / Decimal(12)
        case .year: 52
        }
    }

    static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}
