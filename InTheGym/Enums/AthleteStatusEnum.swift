//
//  AthleteStatusEnum.swift
//  InTheGym
//
//  Created by Findlay Wood on 05/08/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit

/// current training status of the athlete - default to in season
enum AthleteStatus: String, Codable, CaseIterable {
    case inSeason
    case preSeason
    case offSeason
    case injured
    case rehab
    case holiday
    
    /// text colout to show on athlete card
    var textColour: UIColor {
        switch self {
        case .inSeason, .offSeason, .preSeason:
            return .label
        case .injured:
            return .red
        case .rehab:
            return .yellow
        case .holiday:
            return .orange
        }
    }
    
    /// text for label on athlete card
    var title: String {
        switch self {
        case .inSeason:
            return "In Season"
        case .preSeason:
            return "Pre Season"
        case .offSeason:
            return "Off Season"
        case .injured:
            return "Injured"
        case .rehab:
            return "Rehab"
        case .holiday:
            return "Holiday"
        }
    }
    
    /// meaage to represent status
    var message: String {
        switch self {
        case .inSeason:
            return "You are currently in season/in competition and have regularly scheduled games/events."
        case .preSeason:
            return "You are only a few weeks from starting a season/competition and are currently preparing for that."
        case .offSeason:
            return "You are currently doing off season training. The next competition/season is a while away yet you are still regularly training."
        case .injured:
            return "You are currently injured and are unable to partake in any form of training."
        case .rehab:
            return "You are currently injured but are able to partake in various aspects of training, including rehabbing your injury."
        case .holiday:
            return "You are currently on holiday enjoying a break from training."
        }
    }
    
    /// icon to represent status
    var icon: UIImage? {
        switch self {
        case .inSeason:
            return UIImage(named: "trophy_icon")
        case .preSeason:
            return UIImage(named: "running_icon")
        case .offSeason:
            return UIImage(named: "offseason_icon")
        case .injured:
            return UIImage(named: "injury_icon")
        case .rehab:
            return UIImage(named: "rehab_icon")
        case .holiday:
            return UIImage(named: "beach_icon")
        }
    }
}
