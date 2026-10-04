//
//  ProfileDetails.swift
//  ProfileKit
//
//  Created by Findlay Wood on 03/10/2026.
//
import Foundation

/// The text Edit Profile can change: display name and bio. What is saved, not
/// what is shown. The photo travels separately, through `ProfilePhotoUploader`.
///
/// **The limits are the account-creation limits** (`AccountCreationHomeViewModel`:
/// 100 and 300), so a name or bio that was valid at signup is valid to edit.
/// They must also match the `Users/{userId}` update rule in `PROFILE_PLAN.md`
/// step 3. Change one and you change all three.
public struct ProfileDetails: Equatable, Sendable {

    public static let displayNameLimit = 100
    public static let bioLimit = 300

    public let displayName: String
    public let bio: String

    public init(displayName: String, bio: String) {
        self.displayName = displayName
        self.bio = bio
    }

    /// Leading and trailing whitespace is dropped before saving, so a name of
    /// spaces is no name and a bio of blank lines is no bio. The header already
    /// treats a whitespace-only bio as absent, and this keeps what is stored
    /// matching what is shown.
    var trimmed: ProfileDetails {
        ProfileDetails(
            displayName: displayName.trimmingCharacters(in: .whitespacesAndNewlines),
            bio: bio.trimmingCharacters(in: .whitespacesAndNewlines)
        )
    }
}
