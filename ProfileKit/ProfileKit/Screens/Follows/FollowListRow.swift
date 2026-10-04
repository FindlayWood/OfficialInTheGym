//
//  FollowListRow.swift
//  ProfileKit
//
//  Created by Findlay Wood on 04/10/2026.
//
import SwiftUI

/// One person in a follow list: avatar, name over @username, and the follow
/// button. The photo loads with the row and the placeholder holds the slot.
///
/// A row whose profile could not be found still draws, as "Unknown user". A
/// deleted account's follow can outlive it by a trigger's latency, and a gap
/// in the list would be stranger than a name saying so.
struct FollowListRow: View {

    let row: FollowListViewModel.Row
    let kind: FollowListKind
    let photoLoader: ProfilePhotoLoader
    var showsDivider = true
    let onToggleFollow: () -> Void
    var onRemove: (() -> Void)?
    /// The person's name and photo open their profile; the button and menu
    /// keep their own taps.
    var onOpenProfile: (() -> Void)?

    @State private var photo: UIImage?

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                Button {
                    onOpenProfile?()
                } label: {
                    HStack(spacing: 12) {
                        ProfileAvatar(photo: photo, size: 44)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(row.summary?.displayName ?? "Unknown user")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(row.summary == nil ? Color.secondary : Color.primary)
                                .lineLimit(1)
                            if let username = row.summary?.username {
                                Text("@\(username)")
                                    .font(.system(size: 13))
                                    .foregroundStyle(Color.secondary)
                                    .lineLimit(1)
                            }
                        }
                        Spacer(minLength: 8)
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .disabled(onOpenProfile == nil)
                if let status = row.status {
                    FollowButton(status: status, followsYou: kind == .followers, action: onToggleFollow)
                }
                if let onRemove {
                    Menu {
                        Button("Remove Follower", systemImage: "person.badge.minus", role: .destructive, action: onRemove)
                    } label: {
                        Image(systemName: "ellipsis")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(Color.secondary)
                            .frame(width: 32, height: 32)
                    }
                    .accessibilityLabel("More options")
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            if showsDivider {
                Divider().padding(.leading, 72)
            }
        }
        .task(id: row.userId) {
            photo = try? await photoLoader.photo(for: row.userId)
        }
    }
}
