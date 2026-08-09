//
//  PurchaseErrorBanner.swift
//  InTheGym
//
//  Created by Findlay Wood on 09/08/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//

import SwiftUI

/// One banner for every `PurchaseError`, reading `error.description`.
///
/// The paywall had four near-identical `case` branches, each with its own hardcoded sentence and its
/// own red "Try Again" button — while `PurchaseError.description`, which already says all four
/// things, went unused.
struct PurchaseErrorBanner: View {

    let message: String
    let onRetry: () -> Void

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

            Button(action: onRetry) {
                Text("Try Again")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color.red)
            }
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

#Preview {
    PurchaseErrorBanner(message: PurchaseError.loadingProducts.description) {}
        .padding()
}
