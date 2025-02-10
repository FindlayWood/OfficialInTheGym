//
//  Product+Extension.swift
//  InTheGym
//
//  Created by Findlay Wood on 10/02/2025.
//  Copyright © 2025 FindlayWood. All rights reserved.
//

import Foundation
import StoreKit

extension Product: PurchaseableProduct {
    func purchaseProduct() async throws -> PurchaseProductResult {
        let result = try await self.purchase()
        
        switch result {
        case let .success(.verified(transaction)):
           // Successful purhcase
            await transaction.finish()
            let t = PurchaseTransaction(
                id: "\(transaction.id)",
                productID: transaction.productID,
                purchaseDate: transaction.purchaseDate
            )
            return .successVerified(t)
        case .success(.unverified(_, _)):
            // Successful purchase but transaction/receipt can't be verified
            // Could be a jailbroken phone
            return .successUnverified
        case .pending:
            // Transaction waiting on SCA (Strong Customer Authentication) or
            // approval from Ask to Buy
            return .pending
        case .userCancelled:
            // ^^^
            return .userCancelled
        @unknown default:
            return .failed
        }
    }
}

extension Product: DisplayableProduct {
    
    var period: String {
        return getSubscriptionPeriod(product: self).rawValue.capitalized
    }
    
    var perPeriod: String {
        return getSubscriptionPeriod(product: self).perPeriod
    }
    
    func getSubscriptionPeriod(product: Product) -> StoreKitSubscriptionPeriod {
        if let subscription = product.subscription {
            
            let unit = subscription.subscriptionPeriod.unit
            let value = subscription.subscriptionPeriod.value
            
            switch unit {
            case .day:
                return .none
            case .week:
                return .weekly
            case .month:
                switch value {
                case 1:
                    return .monthly
                case 2:
                    return .everyTwoMonths
                case 3:
                    return .everyThreeMonths
                case 6:
                    return .everySixMonths
                default:
                    fatalError("ERROR: YOU HAVE NOT CONSIDERED ALL MONTHLY VALUES.")
                }
            case .year:
                return .yearly
            @unknown default:
                fatalError("ERROR: YOU HAVE NOT CONSIDERED ALL SUBSCRIPTION UNITS.")
            }
        } else {
            return .none
        }
    }
    
    enum StoreKitSubscriptionPeriod: String {
        case none
        case weekly
        case monthly
        case everyTwoMonths
        case everyThreeMonths
        case everySixMonths
        case yearly
        
        var perPeriod: String {
            switch self {
            case .weekly:
                return "week"
            case .monthly:
                return "month"
            case .yearly:
                return "year"
            default:
                return "N/A"
            }
        }
    }
}
