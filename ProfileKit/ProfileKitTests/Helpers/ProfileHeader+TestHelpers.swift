//
//  ProfileHeader+TestHelpers.swift
//  ProfileKitTests
//
//  Created by Findlay Wood on 03/10/2026.
//
import Foundation
@testable import ProfileKit

extension ProfileHeader {

    static func make(
        userId: String = "u1",
        isVerified: Bool = false,
        isElite: Bool = false
    ) -> ProfileHeader {
        ProfileHeader(
            userId: userId,
            displayName: "Display Name",
            username: "username",
            bio: "",
            isVerified: isVerified,
            isElite: isElite
        )
    }
}
