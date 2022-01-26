//
//  FirebaseStorage.swift
//  InTheGym
//
//  Created by Findlay Wood on 25/01/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
import Firebase

// MARK: - Firebsae Storage Protocol
///Models that have a path to Firebase Storage
protocol FirebaseStoragePath {
    
    ///The String variable that holds the path to the data in Firebase Storage
    ///Requires the id from the model which could be a user or group
    var storagePath: String { get }
}

// MARK: - Firebase Storage Upload Protocol
///Has data to be uploaded and metaData to be stored
///Requires FirebaseStoragePath for access to a storage path
protocol FirebaseStorageUpload: FirebaseStoragePath {
    
    ///The data that is to be stored in Firebase Database
    ///Optional type as usually requires some kind of compression which returns an optional
    var data: Data? { get }
    
    ///The metaData of the data stored
    ///Information about the data stored
    var metaData: StorageMetadata { get }
}

// MARK: - TypeAlia
typealias FirebaseStorage = FirebaseStoragePath & FirebaseStorageUpload

// MARK: - Example
///Profile Image Example
///Takes the user/group ID and the image
///Compresses the image ready for uploading and returns as Data
///Sets the metaData contentType tp "image/jpg"
///Storage path is "ProfilePhotos/CurrentUserID"
///
//struct ProfileImageModel {
//    var id: String
//    var image: UIImage
//}
//extension ProfileImageModel: FirebaseStorage {
//    var storagePath: String {
//        return "ProfilePhotos/\(id)"
//    }
//    var data: Data? {
//        let data = image.jpegData(compressionQuality: 0.4)
//        return data
//    }
//    var metaData: StorageMetadata {
//        let metaData = StorageMetadata()
//        metaData.contentType = "image/jpg"
//        return metaData
//    }
//}
