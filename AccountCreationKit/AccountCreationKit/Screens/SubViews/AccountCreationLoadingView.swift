//
//  AccountCreationLoadingView.swift
//  AccountCreationKit
//
//  Created by Findlay Wood on 09/08/2026.
//

import SwiftUI

/// The card was hardcoded `Color.white` — a white slab in dark mode — and carried no text, so the
/// longest wait in onboarding said nothing about what was happening.
struct AccountCreationLoadingView: View {

    @State private var isAnimating = false

    private var animation: Animation {
        Animation.linear(duration: 2)
            .repeatForever(autoreverses: false)
    }

    var body: some View {
        ZStack {
            Color.black.opacity(0.4)

            VStack(spacing: 16) {
                Circle()
                    .trim(from: 0.2, to: 1)
                    .stroke(Color.darkColor, style: StrokeStyle(lineWidth: 6, lineCap: .round, lineJoin: .round))
                    .frame(width: 40, height: 40)
                    .rotationEffect(.degrees(isAnimating ? 360 : 0))
                    .animation(animation, value: isAnimating)
                    .onAppear { isAnimating = true }

                Text("Creating your account...")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(Color.primary)
            }
            .padding(.horizontal, 32)
            .padding(.vertical, 28)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color(.secondarySystemBackground))
            )
        }
        .ignoresSafeArea()
    }
}

#Preview {
    AccountCreationLoadingView()
}
