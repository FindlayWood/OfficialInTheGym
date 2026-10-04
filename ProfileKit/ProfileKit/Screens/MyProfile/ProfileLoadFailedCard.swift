//
//  ProfileLoadFailedCard.swift
//  ProfileKit
//
//  Created by Findlay Wood on 03/10/2026.
//

import SwiftUI

/// Shown when the header could not load, with a way to try again. It uses the
/// tinted "Try Again" style from `MyDayWorkoutLibraryScreen`.
struct ProfileLoadFailedCard: View {

    var title = "Couldn't Load Profile"
    let onRetry: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 28, weight: .semibold))
                .foregroundStyle(Color.secondary)
            Text(title)
                .font(.system(size: 17, weight: .semibold))
            Text("Check your connection and try again.")
                .font(.system(size: 14))
                .foregroundStyle(Color.secondary)
                .multilineTextAlignment(.center)
            Button(action: onRetry) {
                Text("Try Again")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Color.darkColor)
                    .padding(.horizontal, 20)
                    .frame(height: 40)
                    .background(Color.darkColor.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
            .padding(.top, 4)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 28)
        .padding(.horizontal, 20)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.secondarySystemBackground))
        )
    }
}
