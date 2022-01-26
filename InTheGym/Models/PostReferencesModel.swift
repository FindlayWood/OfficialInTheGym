//
//  PostReferencesModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 26/01/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation

struct PostReferencesModel: FirebaseModel {
    static var path: String {
        return "PostSelfReferences/\(FirebaseAuthManager.currentlyLoggedInUser.uid)"
    }
}
