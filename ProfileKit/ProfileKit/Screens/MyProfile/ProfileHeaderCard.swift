//
//  ProfileHeaderCard.swift
//  ProfileKit
//
//  Created by Findlay Wood on 03/10/2026.
//

import SwiftUI

/// The identity card at the top of a profile: photo, display name with its
/// stamps, @username, then the bio.
///
/// Centred, as the legacy header was, because it is the one thing on the screen
/// about a person rather than a list of things. The stamps sit inline after the
/// name rather than on a row of their own. The legacy `UserStampsView` gave them
/// a full row, which mostly drew an empty gap, since most users have none.
///
/// An empty bio draws nothing, not a prompt. This card is also what other people
/// will see (step 7), and "Add a bio" on someone else's profile is a dead end.
/// Prompting belongs on Edit Profile (step 3).
struct ProfileHeaderCard: View {

    let header: ProfileHeader
    let photo: UIImage?
    let stamps: [ProfileStamp]

    var body: some View {
        VStack(spacing: 14) {
            ProfileAvatar(photo: photo)

            VStack(spacing: 4) {
                HStack(spacing: 6) {
                    Text(header.displayName)
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(Color.primary)
                        .multilineTextAlignment(.center)
                    ForEach(stamps) { stamp in
                        Image(systemName: stamp.systemImage)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(stamp.color)
                            .accessibilityLabel(stamp.accessibilityLabel)
                    }
                }
                Text("@\(header.username)")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(Color.secondary)
            }

            if !header.bio.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                Text(header.bio)
                    .font(.system(size: 15))
                    .foregroundStyle(Color.primary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .padding(.horizontal, 20)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.secondarySystemBackground))
        )
    }
}
