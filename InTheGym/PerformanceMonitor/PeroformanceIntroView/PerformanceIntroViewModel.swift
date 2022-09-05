//
//  PerformanceIntroViewModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 01/07/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
import Combine
import UIKit

class PerformanceIntroViewModel {
    // MARK: - Publishers
    var action = PassthroughSubject<PerformanceIntroOptions,Never>()
}

enum PerformanceIntroOptions: CaseIterable {
    case workload
    case wellness
    case trainingStatus
    case verticalJump
    case cmj
    case injury
    case journal
    
    var image: UIImage {
        switch self {
        case .workload:
            return UIImage(systemName: "chart.bar.xaxis", withConfiguration: UIImage.SymbolConfiguration(pointSize: 50))!
        case .wellness:
            return UIImage(named: "wellness_icon")!
        case .trainingStatus:
            return UIImage(named: "calendar_icon")!
        case .verticalJump:
            return UIImage(named: "jump_icon")!
        case .cmj:
            return UIImage(named: "bolt_icon")!
        case .injury:
            return UIImage(named: "injury_icon")!
        case .journal:
            return UIImage(named: "journal_icon")!
        }
    }
    
    var title: String {
        switch self {
        case .workload:
            return "Workload"
        case .wellness:
            return "Wellness"
        case .trainingStatus:
            return "Training Status"
        case .verticalJump:
            return "Vertical Jump"
        case .cmj:
            return "CMJ"
        case .injury:
            return "Injury Tracker"
        case .journal:
            return "Journal"
        }
    }
    
    var message: String {
        switch self {
        case .workload:
            return "Monitor your workload. See all workload for every session recoreded and add custom sessions. See more info including ACWR, training strain and more..."
        case .wellness:
            return "Answer some questions about your wellbeing to calculate your wellness score. This is most accurate when taken daily."
        case .trainingStatus:
            return "Update your current training status. Let you coaches know what training cycle you are on."
        case .verticalJump:
            return "Measure your vertical jump. Make use of high speed video to record your jumps and then tag them to measure your jump height."
        case .cmj:
            return "Counter Movement Jump. Monitor your lower body power, either to check your power or monitor your fatigue levels. See the CMJ instructions, most recent output and several CMJ variations."
        case .injury:
            return "Update your injury status and track your recovery times and previous injuries."
        case .journal:
            return "Keep a private journal of your every day."
        }
    }
}
