//
//  ProfileSections+Items.swift
//  InTheGym
//
//  Created by Findlay Wood on 11/02/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation

enum ProfileSections {
    case mainInfo
    case profileOptions
    case posts
}

enum ProfileItems: Hashable {
    case userInfo(UserProfileModel)
    case options
    case posts(PostModel)
}
