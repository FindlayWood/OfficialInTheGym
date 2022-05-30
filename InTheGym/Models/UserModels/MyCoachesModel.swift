//
//  MyCoachesModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 30/05/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation

struct MyCoachesSearchModel {
    var userID: String
}
extension MyCoachesSearchModel: FirebaseInstance {
    var internalPath: String {
        "PlayerCoaches/\(userID)"
    }
}
