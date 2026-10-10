//
//  PerformanceLockedScreen.swift
//  PerformanceKit
//
//  Created by Findlay Wood on 10/10/2026.
//
import SwiftUI

/// What the PERFORMANCE tab shows without INTHEGYM pro: what the tab is for,
/// and the way to the paywall as the bottom button. In emulator builds only, a
/// quiet "Unlock for testing" under it lets the tab be used without a purchase.
struct PerformanceLockedScreen: View {

    @ObservedObject var viewModel: PerformanceGateViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                PerformanceIconTile(systemName: "lock.fill", size: 64)
                    .padding(.top, 32)
                Text("Performance is part of INTHEGYM pro")
                    .font(.system(size: 22, weight: .bold))
                    .multilineTextAlignment(.center)
                Text("Measure your jumps on camera, track them over time, and check every week whether you're fresh or fatigued.")
                    .font(.system(size: 15))
                    .foregroundStyle(Color.secondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 32)
        }
        .background(Color(.systemBackground).ignoresSafeArea())
        .performanceBottomBar {
            VStack(spacing: 12) {
                PerformancePrimaryButton(title: "See INTHEGYM pro") {
                    viewModel.showPaywall()
                }
                if viewModel.canUnlockForTesting {
                    Button("Unlock for testing (emulator)") {
                        viewModel.unlockForTesting()
                    }
                    .font(.system(size: 14, weight: .medium))
                    .tint(Color.secondary)
                }
            }
        }
    }
}
