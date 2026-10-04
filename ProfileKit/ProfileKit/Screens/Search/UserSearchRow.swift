//
//  UserSearchRow.swift
//  ProfileKit
//
//  Created by Findlay Wood on 04/10/2026.
//

import SwiftUI

/// One search result: avatar, name over @username, chevron. The whole row
/// opens the profile. There is no follow button here, since following is a
/// decision made on the profile, not from a name in a list of matches.
struct UserSearchRow: View {

    let summary: ProfileSummary
    let photoLoader: ProfilePhotoLoader
    var showsDivider = true
    let onTap: () -> Void

    @State private var photo: UIImage?

    var body: some View {
        VStack(spacing: 0) {
            Button(action: onTap) {
                HStack(spacing: 12) {
                    ProfileAvatar(photo: photo, size: 44)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(summary.displayName)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(Color.primary)
                            .lineLimit(1)
                        Text("@\(summary.username)")
                            .font(.system(size: 13))
                            .foregroundStyle(Color.secondary)
                            .lineLimit(1)
                    }
                    Spacer(minLength: 8)
                    Image(systemName: "chevron.right")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Color(.tertiaryLabel))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            if showsDivider {
                Divider().padding(.leading, 72)
            }
        }
        .task(id: summary.userId) {
            photo = try? await photoLoader.photo(for: summary.userId)
        }
    }
}
