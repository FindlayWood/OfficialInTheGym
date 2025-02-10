//
//  RemoteUploadPurchaseTransaction.swift
//  InTheGym
//
//  Created by Findlay Wood on 10/02/2025.
//  Copyright © 2025 FindlayWood. All rights reserved.
//

import Foundation

struct RemoteUploadPurchaseTransaction: Codable {
    let id: String
    let userID: String
    let productID: String
    let purchaseDate: Date
}
