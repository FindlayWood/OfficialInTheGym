//
//  ProfilePhotoUploader.swift
//  ProfileKit
//
//  Created by Findlay Wood on 03/10/2026.
//
import UIKit

/// Replaces the signed-in user's profile photo. Sizing and encoding are the
/// adapter's: they depend on how the app downloads photos, which ProfileKit
/// does not know.
public protocol ProfilePhotoUploader {
    func upload(_ photo: UIImage) async throws
}
