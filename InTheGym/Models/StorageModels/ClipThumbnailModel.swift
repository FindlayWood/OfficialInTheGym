//
//  ClipThumbnailModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 09/02/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
import UIKit
import FirebaseStorage

// MARK: - Clip Thumbnail Upload Model
///Takes the clipID and the image
///Compresses the image ready for uploading and returns as Data
///Sets the metaData contentType tp "clipThumbnail/jpg"
///Storage path is "ClipThumbnails/id"
///
struct ClipThumbnailModel {
    var id: String
    var image: UIImage
}
extension ClipThumbnailModel: FirebaseStorageData {
    var storagePath: String {
        return "ClipThumbnails/\(id)"
    }
    var data: Data? {
        let data = image.jpegData(compressionQuality: 0.4)
        return data
    }
    var metaData: StorageMetadata {
        let metaData = StorageMetadata()
        metaData.contentType = "clipThumbnail/jpg"
        return metaData
    }
}

// MARK: - Clip Thumbnail Download Model
///Takes an id of clip
///Provides path to storage reference
///Returns UIImage from Firebase Storage
struct ClipThumbnailDownloadModel {
    var id: String
}
extension ClipThumbnailDownloadModel: FirebaseStoragePath {
    var storagePath: String {
        return "ClipThumbnails/\(id)"
    }
}
