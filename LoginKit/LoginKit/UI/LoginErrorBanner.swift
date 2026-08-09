//
//  LoginErrorBanner.swift
//  LoginKit
//
//  Created by Findlay Wood on 09/08/2026.
//

import SwiftUI

/// Mirrors `AccountCreationErrorBanner`. Errors here used to be a bare line of red text with no
/// weight to it.
struct LoginErrorBanner: View {

    let message: String

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Color.red)
            Text(message)
                .font(.system(size: 13))
                .foregroundStyle(Color.primary)
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 11)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.red.opacity(0.12))
        )
        .transition(.opacity)
    }
}
