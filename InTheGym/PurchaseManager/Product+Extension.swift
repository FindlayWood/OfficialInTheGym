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
                productID: transaction.productID,
                purchaseDate: transaction.purchaseDate,
                transactionID: "\(transaction.id)"
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
