//
//  DiscoverSectionMessage.swift
//  DiscoverKit
//
//  Created by Findlay Wood on 28/09/2026.
//

import SwiftUI

/// The body of a section with nothing to list — either genuinely empty, or
/// failed with a Try Again. Two different messages on purpose: "nothing here
/// yet" for a network error is the lie the workout library used to tell.
struct DiscoverSectionMessage: View {
    let message: String
    var retry: (() -> Void)?

    var body: some View {
        VStack(spacing: 10) {
            Text(message)
                .font(.system(size: 14))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            if let retry {
                Button(action: retry) {
                    Text("Try Again")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color.darkColor)
                }
                .buttonStyle(.plain)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .padding(.horizontal, 16)
    }
}
