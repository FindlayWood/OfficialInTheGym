//
//  StorageProfilePhotoUploader.swift
//  InTheGym
//
//  Created by Findlay Wood on 03/10/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//
import ProfileKit
import UIKit

/// Uploads a new profile photo to Storage `ProfilePhotos/{uid}`, replacing the
/// old one.
///
/// **Sized to what the app can download.** `FirebaseStorageManager.downloadImage`
/// refuses anything over `720 * 720` bytes (about 506 KB), so a photo stored
/// larger would upload and then never load anywhere. The photo is scaled to
/// 720pt on its long side, then JPEG-compressed at falling quality until it fits.
/// Signup's uploader sidesteps the same limit with a flat 0.1 quality, which
/// is why signup photos look rough.
struct StorageProfilePhotoUploader: ProfilePhotoUploader {

    static let maxDimension: CGFloat = 720
    static let maxBytes = 720 * 720

    let userId: String
    var storageService = FirebaseStorageManager.shared

    func upload(_ photo: UIImage) async throws {
        guard let data = Self.encode(photo) else { throw EncodingError() }
        try await storageService.dataUploadAsync(data: data, at: "ProfilePhotos/\(userId)")
    }

    static func encode(_ photo: UIImage) -> Data? {
        let scaled = scale(photo)
        for quality in stride(from: 0.8, through: 0.2, by: -0.15) {
            if let data = scaled.jpegData(compressionQuality: quality), data.count <= maxBytes {
                return data
            }
        }
        return nil
    }

    private static func scale(_ photo: UIImage) -> UIImage {
        let longSide = max(photo.size.width, photo.size.height)
        guard longSide > maxDimension else { return photo }
        let factor = maxDimension / longSide
        let size = CGSize(width: photo.size.width * factor, height: photo.size.height * factor)
        let format = UIGraphicsImageRendererFormat.default()
        format.scale = 1
        return UIGraphicsImageRenderer(size: size, format: format).image { _ in
            photo.draw(in: CGRect(origin: .zero, size: size))
        }
    }

    struct EncodingError: Error {}
}
