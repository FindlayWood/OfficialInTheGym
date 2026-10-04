//
//  FollowRequestRow.swift
//  ProfileKit
//
//  Created by Findlay Wood on 04/10/2026.
//

import SwiftUI

/// One request: who is asking, then Approve (filled) and Decline (tinted), or
/// "Approved" once approved. The same layout as `FollowListRow`, so the inbox
/// reads as another follow list.
struct FollowRequestRow: View {

    let row: FollowRequestsViewModel.Row
    let photoLoader: ProfilePhotoLoader
    var showsDivider = true
    let onApprove: () -> Void
    let onDecline: () -> Void

    @State private var photo: UIImage?

    var body: some View {
        VStack(spacing: 0) {
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
                if row.isApproved {
                    Label("Approved", systemImage: "checkmark")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color.secondary)
                } else {
                    HStack(spacing: 8) {
                        actionButton("Approve", filled: true, action: onApprove)
                        actionButton("Decline", filled: false, action: onDecline)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .animation(.easeInOut(duration: 0.15), value: row.isApproved)
            if showsDivider {
                Divider().padding(.leading, 72)
            }
        }
        .task(id: row.userId) {
            photo = try? await photoLoader.photo(for: row.userId)
        }
    }

    private func actionButton(_ title: String, filled: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(filled ? Color.white : Color.darkColor)
                .padding(.horizontal, 12)
                .frame(height: 32)
                .background(filled ? Color.darkColor : Color.darkColor.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}
