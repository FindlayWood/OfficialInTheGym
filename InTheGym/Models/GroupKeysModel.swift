//
//  GroupsModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 31/12/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation

// MARK: - Groups Model

struct GroupKeysModel {
    var id: String
}
extension GroupKeysModel: FirebaseResource {
    static var path: String {
        return "GroupsReferences/\(FirebaseAuthManager.currentlyLoggedInUser.uid)"
    }
    var internalPath: String {
        return "Groups/\(id)"
    }
}
