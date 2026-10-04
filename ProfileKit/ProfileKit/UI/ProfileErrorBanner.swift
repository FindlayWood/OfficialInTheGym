//
//  ProfileErrorBanner.swift
//  ProfileKit
//
//  Created by Findlay Wood on 03/10/2026.
//

import SwiftUI

/// A failed save, shown in the screen rather than as an alert, so whatever the
/// user was editing stays in view while they decide what to do. Used by Edit
/// Profile and Body Measurements. ProfileKit's
/// copy of `AccountCreationErrorBanner` / `LoginErrorBanner`. **Keep the set in
/// step** until the shared UI framework exists.
struct ProfileErrorBanner: View {

    let message: String

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color.red)
            Text(message)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(Color.primary)
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 0)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.red.opacity(0.1))
        )
    }
}
