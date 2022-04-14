//
//  ProfileImageUploadModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 26/01/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
import UIKit
import FirebaseStorage

// MARK: - Profile Image Upload Model
///Takes the user/group ID and the image
///Compresses the image ready for uploading and returns as Data
///Sets the metaData contentType tp "image/jpg"
///Storage path is "ProfilePhotos/CurrentUserID"
///
struct ProfileImageUploadModel {
    var id: String
    var image: UIImage
}
extension ProfileImageUploadModel: FirebaseStorageData {
    var storagePath: String {
        return "ProfilePhotos/\(id)"
    }
    var data: Data? {
        let data = image.jpegData(compressionQuality: 0.4)
        return data
    }
    var metaData: StorageMetadata {
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpeg"
        return metaData
    }
}

// MARK: - Profile Image Download Model
///Takes an id of user/group
///Provides path to storage reference
///Returns UIImage from Firebase Storage
struct ProfileImageDownloadModel {
    var id: String
}
extension ProfileImageDownloadModel: FirebaseStoragePath {
    var storagePath: String {
        return "ProfilePhotos/\(id)"
    }
}
