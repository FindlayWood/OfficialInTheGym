//
//  LoadingView.swift
//  LoginKit
//
//  Created by Findlay-Personal on 04/04/2023.
//

import SwiftUI

/// The card was hardcoded `Color.white` — a white slab in dark mode.
struct LoadingView: View {

    @State private var isAnimating = false

    private var animation: Animation {
        Animation.linear(duration: 2)
            .repeatForever(autoreverses: false)
    }

    var body: some View {
        ZStack {
            Color.black.opacity(0.4)

            Circle()
                .trim(from: 0.2, to: 1)
                .stroke(Color.darkColor, style: StrokeStyle(lineWidth: 6, lineCap: .round, lineJoin: .round))
                .frame(width: 40, height: 40)
                .rotationEffect(.degrees(isAnimating ? 360 : 0))
                .animation(animation, value: isAnimating)
                .onAppear { isAnimating = true }
                .padding(36)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color(.secondarySystemBackground))
                )
        }
        .ignoresSafeArea()
    }
}

#Preview {
    LoadingView()
}
