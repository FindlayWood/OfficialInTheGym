//
//  ClipUploadError.swift
//  InTheGym
//
//  Created by Findlay Wood on 09/02/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation

enum ClipUploadError: Error {
    case failedGenerateThumnail
    case failedUploadThumbnail
    case failedClipToStorage
    case failedDatabaseUpload
}
