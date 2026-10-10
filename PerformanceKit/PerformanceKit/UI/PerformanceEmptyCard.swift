//
//  PerformanceEmptyCard.swift
//  PerformanceKit
//
//  Created by Findlay Wood on 10/10/2026.
//
import SwiftUI

/// A card that says there is nothing here yet, or a spinner while loading, so
/// a section keeps its place instead of vanishing.
struct PerformanceEmptyCard: View {

    let message: String
    var isLoading = false

    var body: some View {
        Group {
            if isLoading {
                ProgressView()
            } else {
                Text(message)
                    .font(.system(size: 14))
                    .foregroundStyle(Color.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .padding(.horizontal, 16)
        .performanceCard()
    }
}
