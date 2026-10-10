//
//  PerformanceCard.swift
//  PerformanceKit
//
//  Created by Findlay Wood on 10/10/2026.
//
import SwiftUI

extension View {

    /// The card every PerformanceKit screen draws on: `secondarySystemBackground`
    /// at radius 16 on a `systemBackground` page, no shadow, no stroke. MyDay's
    /// and ProfileKit's card, so the tab reads as the same app. **The one
    /// definition of it here**: the legacy screens each drew their own, white
    /// with drop shadows, which was unreadable in dark mode.
    func performanceCard() -> some View {
        background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.secondarySystemBackground))
        )
    }
}
