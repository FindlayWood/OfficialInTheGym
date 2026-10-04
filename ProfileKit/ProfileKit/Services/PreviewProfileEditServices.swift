//
//  PreviewProfileEditServices.swift
//  ProfileKit
//
//  Created by Findlay Wood on 03/10/2026.
//
import UIKit

/// Preview conformer for Edit Profile. Both writes succeed and store nothing.
public final class PreviewProfileEditServices: ProfileDetailsWriter, ProfilePhotoUploader, @unchecked Sendable {
    public init() {}

    public func save(_ details: ProfileDetails) async throws {}

    public func upload(_ photo: UIImage) async throws {}
}
