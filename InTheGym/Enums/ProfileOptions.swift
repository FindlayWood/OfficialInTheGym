//
//  ProfileOptions.swift
//  InTheGym
//
//  Created by Findlay Wood on 11/02/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
import UIKit

enum ProfileOptions: CaseIterable {
    case savedWorkouts
    case createdWorkouts
    case scores
    case edit
    case more
    
    var image: UIImage {
        switch self {
        case .savedWorkouts:
            return UIImage(named: "benchpress_icon")!
        case .createdWorkouts:
            return UIImage(named: "hammer_icon")!
        case .scores:
            return UIImage(named: "scores_icon")!
        case .edit:
            return UIImage(named: "edit_icon")!
        case .more:
            return UIImage(named: "more_icon")!
        }
    }
}
