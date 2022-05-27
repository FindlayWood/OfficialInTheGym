//
//  ProfilePageSections+Items.swift
//  InTheGym
//
//  Created by Findlay Wood on 15/04/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation

enum ProfilePageSections: CaseIterable {
    case UserInfo
    case UserData
    case Spacer
}

enum ProfilePageItems: Hashable {
    case profileInfo(Users)
    case post(PostModel)
    case workout(SavedWorkoutModel)
    case clip(ClipModel)
    case spacer
}
