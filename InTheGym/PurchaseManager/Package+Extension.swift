//
//  Package+Extension.swift
//  InTheGym
//
//  Created by Findlay Wood on 10/02/2025.
//  Copyright © 2025 FindlayWood. All rights reserved.
//

import Foundation
import RevenueCat

extension Package: DisplayAndPurchaseProduct {
    var displayPrice: String {
        self.storeProduct.localizedPriceString
    }
    
    var period: String {
        switch self.storeProduct.subscriptionPeriod?.unit {
        case .day:
            return "day"
        case .week:
            return "weel"
        case .month:
            return "month"
        case .year:
            return "year"
        case nil:
            return "nil"
        }
    }
    
    var perPeriod: String {
        switch self.storeProduct.subscriptionPeriod?.unit {
        case .day:
            return "day"
        case .week:
            return "weel"
        case .month:
            return "month"
        case .year:
            return "year"
        case nil:
            return "nil"
        }
    }
    
    func purchaseProduct() async throws -> PurchaseProductResult {
        let (transaction, customerInfo, userCancelled) = try await Purchases.shared.purchase(package: self)
        if userCancelled {
            return .userCancelled
        } else if let transaction {
            return .successVerified(.init(id: transaction.id, productID: transaction.productIdentifier, purchaseDate: transaction.purchaseDate))
        } else {
            return .failed
        }
    }
    
    
}
