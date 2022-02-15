//
//  GroupsModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 31/12/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation

// MARK: - Group Keys Model
/// Used to fetch group keys for current user then load groups from the key

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

// MARK: - Group References Model
/// Fetch group references for given user
/// Initialize with a user id
struct GroupReferencesModel {
    
    /// the id of the user to search groups
    var id: String
}
extension GroupReferencesModel: FirebaseInstance {
    var internalPath: String {
        return "GroupsReferences/\(id)"
    }
}
