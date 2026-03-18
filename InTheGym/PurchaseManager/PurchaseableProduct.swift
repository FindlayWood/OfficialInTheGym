//
//  PurchaseableProduct.swift
//  InTheGym
//
//  Created by Findlay Wood on 10/02/2025.
//  Copyright © 2025 FindlayWood. All rights reserved.
//

import Foundation

protocol PurchaseableProduct {
    var id: String { get }
    func purchaseProduct() async throws -> PurchaseProductResult
}

enum PurchaseProductResult {
    case successVerified(PurchaseTransaction)
    case successUnverified
    case pending
    case userCancelled
    case failed
}

struct PurchaseTransaction {
    let productID: String
    let purchaseDate: Date
    let transactionID: String
}
