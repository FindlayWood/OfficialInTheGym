//
//  ImageCacheProfilePhotoLoader.swift
//  InTheGym
//
//  Created by Findlay Wood on 03/10/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//
import FirebaseStorage
import ProfileKit
import UIKit

/// Loads `ProfilePhotos/{uid}` from Storage through `ImageCache`, so the photo
/// is shared with every legacy screen that already shows it.
///
/// **A missing object is `nil`, not an error.** Most users have never set a
/// photo, and Storage reports that as `objectNotFound`. Passing it through
/// would log a failure for the common case, and would let a later screen treat
/// "no photo" as "couldn't load".
struct ImageCacheProfilePhotoLoader: ProfilePhotoLoader {

    func photo(for userId: String) async throws -> UIImage? {
        do {
            return try await withCheckedThrowingContinuation { continuation in
                ImageCache.shared.load(from: ProfileImageDownloadModel(id: userId)) { result in
                    continuation.resume(with: result)
                }
            }
        } catch let error as NSError where error.domain == StorageErrorDomain
                    && error.code == StorageErrorCode.objectNotFound.rawValue {
            return nil
        }
    }
}
