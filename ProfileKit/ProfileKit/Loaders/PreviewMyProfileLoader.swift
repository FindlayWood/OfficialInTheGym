//
//  PreviewMyProfileLoader.swift
//  ProfileKit
//
//  Created by Findlay Wood on 03/10/2026.
//
import Foundation

/// Preview conformer that returns a fixed header.
public final class PreviewMyProfileLoader: MyProfileLoader, @unchecked Sendable {

    private let header: ProfileHeader

    public init(header: ProfileHeader = .preview) {
        self.header = header
    }

    public func load() async throws -> ProfileHeader { header }
}

public extension ProfileHeader {
    static let preview = ProfileHeader(
        userId: "preview",
        displayName: "Findlay Wood",
        username: "findlay",
        bio: "Lifting, running, and logging all of it.",
        isVerified: true,
        isElite: false
    )
}
