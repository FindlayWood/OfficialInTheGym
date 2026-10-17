//
//  PurchaseError.swift
//  InTheGym
//
//  Created by Findlay Wood on 11/10/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//

import Foundation

/// Everything the paywall can fail at, each with the sentence `PurchaseErrorBanner` shows.
///
/// `nothingToRestore` is new. Restore used to finish silently whether or not it found anything, so
/// a user with no subscription tapped it, watched a spinner and was left wondering if it had worked.
enum PurchaseError: Equatable {
    case loadingProducts
    case purchasingProduct
    case restorePurchases
    case nothingToRestore
    case handleResult

    var description: String {
        switch self {
        case .loadingProducts:
            return "Couldn't load the plans. Check your connection and try again."
        case .purchasingProduct:
            return "The purchase didn't go through. You haven't been charged."
        case .restorePurchases:
            return "Couldn't restore purchases. Try again later."
        case .nothingToRestore:
            return "No active INTHEGYM pro subscription was found for this Apple ID."
        case .handleResult:
            return "Something went wrong finishing the purchase. Try again later."
        }
    }

    /// Only a failed load has something to retry; the rest are dismissed and the button pressed again.
    var isRetryable: Bool { self == .loadingProducts }
}
