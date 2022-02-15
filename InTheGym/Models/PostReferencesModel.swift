//
//  PostReferencesModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 26/01/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
// MARK: - Post References Model
///Model used to fetch all post keys for given user
///id is the user id of posts to load
struct PostReferencesModel {
    var id: String
}
extension PostReferencesModel: FirebaseInstance {
    var internalPath: String {
        return "PostSelfReferences/\(id)"
    }
}
