//
//  StorageProfileImageUploader.swift
//  InTheGym
//
//  Created by Findlay Wood on 09/08/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//

import AccountCreationKit
import Foundation

struct StorageProfileImageUploader: ProfileImageUploader {

    var storageService = FirebaseStorageManager.shared

    func uploadProfileImage(_ data: Data, for uid: String) async throws {
        try await storageService.dataUploadAsync(data: data, at: "ProfilePhotos/\(uid)")
    }
}
