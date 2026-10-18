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
            return UIImage.legacyIcon("figure.strengthtraining.traditional")
        case .createdWorkouts:
            return UIImage.legacyIcon("hammer.fill")
        case .scores:
            return UIImage.legacyIcon("chart.pie.fill")
        case .edit:
            return UIImage.legacyIcon("pencil")
        case .more:
            return UIImage.legacyIcon("ellipsis.circle.fill")
        }
    }
}
