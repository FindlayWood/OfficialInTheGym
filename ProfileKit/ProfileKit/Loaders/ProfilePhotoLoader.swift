//
//  ProfilePhotoLoader.swift
//  ProfileKit
//
//  Created by Findlay Wood on 03/10/2026.
//
import UIKit

/// Loads a user's profile photo. `nil` means they have not set one, which is
/// not an error: the avatar draws its placeholder either way, and a missing photo
/// must never look like a failed screen.
public protocol ProfilePhotoLoader {
    func photo(for userId: String) async throws -> UIImage?
}
