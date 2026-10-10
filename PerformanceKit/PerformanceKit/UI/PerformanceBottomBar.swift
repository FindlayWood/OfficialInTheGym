//
//  PerformanceBottomBar.swift
//  PerformanceKit
//
//  Created by Findlay Wood on 10/10/2026.
//
import SwiftUI

extension View {

    /// Pins `content`, usually a `PerformancePrimaryButton`, to the bottom of
    /// the screen above the tab bar, on the page colour so scrolled content
    /// passes under it cleanly.
    func performanceBottomBar<Content: View>(@ViewBuilder _ content: () -> Content) -> some View {
        safeAreaInset(edge: .bottom) {
            content()
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 12)
                .background(Color(.systemBackground))
        }
    }
}
