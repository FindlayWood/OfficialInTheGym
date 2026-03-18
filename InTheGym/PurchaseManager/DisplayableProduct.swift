//
//  DisplayableProduct.swift
//  InTheGym
//
//  Created by Findlay Wood on 10/02/2025.
//  Copyright © 2025 FindlayWood. All rights reserved.
//

import Foundation

protocol DisplayableProduct: PurchaseableProduct {
    var id: String { get }
    var displayPrice: String { get }
    var period: String { get }
    var perPeriod: String { get }
}
