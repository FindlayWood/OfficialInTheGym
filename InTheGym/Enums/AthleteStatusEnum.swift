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
            return UIImage.legacyIcon("trophy.fill")
        case .preSeason:
            return UIImage.legacyIcon("figure.run")
        case .offSeason:
            return UIImage.legacyIcon("dumbbell")
        case .injured:
            return UIImage.legacyIcon("bandage.fill")
        case .rehab:
            return UIImage.legacyIcon("bed.double.fill")
        case .holiday:
            return UIImage.legacyIcon("beach.umbrella.fill")
        }
    }
}
