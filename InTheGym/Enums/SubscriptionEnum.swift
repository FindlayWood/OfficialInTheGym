//
//  SubscriptionEnum.swift
//  InTheGym
//
//  Created by Findlay Wood on 16/06/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation

enum SubscriptionEnum {
    case monthly
    case yearly
    
    var price: Double {
        switch self {
        case .monthly:
            return 2.99
        case .yearly:
            return 29.99
        }
    }
}
