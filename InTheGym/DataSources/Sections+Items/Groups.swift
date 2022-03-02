//
//  Groups.swift
//  InTheGym
//
//  Created by Findlay Wood on 02/03/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation

enum GroupSections {
    case groupName
    case groupLeader
    case groupInfo
    case groupPosts
}

enum GroupItems: Hashable {
    case name(GroupModel)
    case leader(Users)
    case info(String)
    case posts(GroupPost)
}
