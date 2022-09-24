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
            return UIImage(named: "bar-chart_icon")!
        case .wellness:
            return UIImage(named: "guru_icon")!
        case .trainingStatus:
            return UIImage(named: "calendar_icon")!
        case .verticalJump:
            return UIImage(named: "jump_icon")!
        case .cmj:
            return UIImage(named: "bolt_icon")!
        case .injury:
            return UIImage(named: "plaster_icon")!
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
            return "Monitor your workload."
        case .wellness:
            return "Complete your daily wellness questions."
        case .trainingStatus:
            return "Update your current training status."
        case .verticalJump:
            return "Measure your vertical jump."
        case .cmj:
            return "Monitor your lower body power output."
        case .injury:
            return "Update your injury status."
        case .journal:
            return "Keep a private journal of your every day."
        }
    }
}
