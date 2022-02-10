//
//  ClipStorageModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 08/02/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
import FirebaseStorage

// MARK: - Clip Storage Model
///Takes the user/group ID and the image
///Compresses the image ready for uploading and returns as Data
///Sets the metaData contentType tp "image/jpg"
///Storage path is "ProfilePhotos/CurrentUserID"
///
struct ClipStorageModel {
    var id: String = UUID().uuidString
    var fileURL: URL
}
extension ClipStorageModel: FirebaseStorageFile {
    
    var file: URL {
        return fileURL
    }
    
    var metaData: StorageMetadata {
        let metaData = StorageMetadata()
        metaData.contentType = "clip.mov"
        return metaData
    }
    
    var storagePath: String {
        return "Clips/\(UserDefaults.currentUser.id)/\(id)"
    }
    
    
}
