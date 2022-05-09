//
//  EditProfileModels.swift
//  InTheGym
//
//  Created by Findlay Wood on 09/05/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation

/// Model to upload changes to profile bio
struct EditProfileBioModel {
    /// the new bio text to upload
    var newBio: String
    /// the upload point in the database
    var uploadPoint: FirebaseMultiUploadDataPoint {
        FirebaseMultiUploadDataPoint(value: newBio, path: internalPath)
    }
}
extension EditProfileBioModel: FirebaseInstance {
    /// the path in the database
    var internalPath: String {
        "users/\(UserDefaults.currentUser.uid)/profileBio"
    }
}
