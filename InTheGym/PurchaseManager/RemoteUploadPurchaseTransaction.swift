//
//  RemoteUploadPurchaseTransaction.swift
//  InTheGym
//
//  Created by Findlay Wood on 10/02/2025.
//  Copyright © 2025 FindlayWood. All rights reserved.
//

import Foundation

struct RemoteUploadPurchaseTransaction: Codable {
    var id: String = UUID().uuidString
    let userID: String
    let productID: String
    let purchaseDate: Date
    let transactionID: String
}
