//
//  WellnessStatus.swift
//  InTheGym
//
//  Created by Findlay Wood on 05/08/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation

enum WellnessStatus: String, Codable, CaseIterable {
    case fresh
    case flow
    case working
    case fatigued
    case burntout
    case rested
    case injured
    case na
    
    var title: String {
        switch self {
        case .fresh:
            return "Fresh"
        case .flow:
            return "Flow"
        case .working:
            return "Working"
        case .fatigued:
            return "Fatigued"
        case .burntout:
            return "Burntout"
        case .rested:
            return "Rested"
        case .injured:
            return "Injured"
        case .na:
            return "n/a"
        }
    }
}
