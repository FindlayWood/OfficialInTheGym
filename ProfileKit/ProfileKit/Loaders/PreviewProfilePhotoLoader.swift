//
//  PreviewProfilePhotoLoader.swift
//  ProfileKit
//
//  Created by Findlay Wood on 03/10/2026.
//
import UIKit

/// Preview conformer with no photo, so previews show the placeholder.
public final class PreviewProfilePhotoLoader: ProfilePhotoLoader, @unchecked Sendable {
    public init() {}

    public func photo(for userId: String) async throws -> UIImage? { nil }
}
