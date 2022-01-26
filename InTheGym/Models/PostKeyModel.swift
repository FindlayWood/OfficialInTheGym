//
//  PostKeyModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 26/01/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation

struct PostKeyModel {
    var id: String
}
extension PostKeyModel: FirebaseInstance {
    var internalPath: String {
        return "Posts/\(id)"
    }
}
