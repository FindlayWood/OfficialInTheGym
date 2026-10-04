//
//  FollowButton.swift
//  ProfileKit
//
//  Created by Findlay Wood on 04/10/2026.
//
import SwiftUI

/// The follow button's three states. **Filled only for "Follow"**, the one
/// that asks for an action. "Following" and "Requested" are tinted, because
/// they report a state. A row of filled buttons would make every row look like
/// it wants something.
struct FollowButton: View {

    let status: FollowStatus
    /// On someone who follows you, "Follow back" says why the button is there.
    var followsYou = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(status == .notFollowing ? Color.white : Color.darkColor)
                .padding(.horizontal, 14)
                .frame(height: 32)
                .background(status == .notFollowing ? Color.darkColor : Color.darkColor.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.15), value: status)
    }

    private var title: String {
        switch status {
        case .notFollowing: followsYou ? "Follow back" : "Follow"
        case .requested: "Requested"
        case .following: "Following"
        }
    }
}
