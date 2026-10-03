//
//  CachingProfilePhotoUploader.swift
//  InTheGym
//
//  Created by Findlay Wood on 03/10/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//
import ProfileKit
import UIKit

/// After a successful upload, puts the new photo in `ImageCache` under the
/// user's id, so the profile and every legacy screen that loads photos through
/// the cache show it at once. Otherwise they keep the old copy for the rest
/// of the session.
///
/// It wraps the uploader rather than being a flag inside it: the Storage
/// uploader knows one destination, and this decides only what happens after it.
struct CachingProfilePhotoUploader: ProfilePhotoUploader {

    let wrapping: ProfilePhotoUploader
    let userId: String

    func upload(_ photo: UIImage) async throws {
        try await wrapping.upload(photo)
        ImageCache.shared.store(photo, for: ProfileImageDownloadModel(id: userId))
    }
}
