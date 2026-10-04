//
//  FollowRequestsBanner.swift
//  ProfileKit
//
//  Created by Findlay Wood on 04/10/2026.
//

import SwiftUI

/// "3 follow requests" under the header, only while any are waiting. The one
/// place requests surface. A private account's inbox has no other door, so it
/// sits where the owner looks first rather than inside Settings.
struct FollowRequestsBanner: View {

    let count: Int
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: "person.badge.plus")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(Color.white)
                    .frame(width: 40, height: 40)
                    .background(Color.darkColor)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                VStack(alignment: .leading, spacing: 2) {
                    Text(count == 1 ? "1 follow request" : "\(count) follow requests")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Color.primary)
                    Text("Approve or decline")
                        .font(.system(size: 13))
                        .foregroundStyle(Color.secondary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color(.tertiaryLabel))
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color(.secondarySystemBackground))
            )
        }
        .buttonStyle(.plain)
    }
}
