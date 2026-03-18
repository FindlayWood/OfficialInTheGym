//
//  PurchaseManagerProtocol.swift
//  InTheGym
//
//  Created by Findlay Wood on 10/02/2025.
//  Copyright © 2025 FindlayWood. All rights reserved.
//

import Foundation

protocol PurchaseManager {
    var hasUnlockedPro: Bool { get }
    var products: [PurchaseableProduct] { get }
    var productsPublished: Published<[PurchaseableProduct]> { get }
    var productsPublisher: Published<[PurchaseableProduct]>.Publisher { get }
    func loadProducts() async throws -> [DisplayAndPurchaseProduct]
    func purchase(_ product: PurchaseableProduct) async throws -> PurchaseProductResult
    func restorePurchase() async throws
}
