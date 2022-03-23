//
//  UserClipsModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 21/03/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation

struct UserClipsModel {
    var id: String
}
extension UserClipsModel: FirebaseInstance {
    var internalPath: String {
        return "UserClips/\(id)"
    }
}
