//
//  InjuryStatus.swift
//  InTheGym
//
//  Created by Findlay Wood on 16/08/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation

enum InjuryStatus: String, CaseIterable, Codable {
    case fit
    case injured
    case rehabbing
    case minorInjury
    
    var title: String {
        switch self {
        case .fit:
            return "Fit"
        case .injured:
            return "Injured"
        case .rehabbing:
            return "Rehabbing"
        case .minorInjury:
            return "Minor"
        }
    }
}
