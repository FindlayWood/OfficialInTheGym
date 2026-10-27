//
//  PerformanceLockedScreen.swift
//  PerformanceKit
//
//  Created by Findlay Wood on 10/10/2026.
//
import SwiftUI

/// What the PERFORMANCE tab shows without INTHEGYM pro: the real dashboard, blurred, drawn from
/// sample sessions, with the way to the paywall over it. In emulator builds only, a quiet "Unlock
/// for testing" under the button lets the tab be used without a purchase.
///
/// **A preview, not a description** — the same decision as StatsKit's `StatsProTeaser` (once its
/// locked screen). It used to be a lock icon over a paragraph, which described a dashboard the user
/// had never seen. Now the actual `PerformanceHomeScreen` renders underneath from
/// `PreviewJumpTestSessionsLoader`, blurred until it reads as cards and numbers rather than results,
/// so nothing on it can be mistaken for the user's own tests. `canRecord: false`, so the preview offers no start button to tap through to.
struct PerformanceLockedScreen: View {

    @ObservedObject var viewModel: PerformanceGateViewModel

    @StateObject private var preview = PerformanceDashboardViewModel(
        loader: PreviewJumpTestSessionsLoader(),
        canRecord: false
    )

    var body: some View {
        ZStack {
            PerformanceHomeScreen(viewModel: preview)
                .scrollDisabled(true)
                .blur(radius: 10)
                .allowsHitTesting(false)
                .accessibilityHidden(true)

            lockCard
                .padding(.horizontal, 24)
        }
        .clipped()
        .background(Color(.systemBackground).ignoresSafeArea())
    }

    private var lockCard: some View {
        VStack(spacing: 14) {
            PerformanceIconTile(systemName: "lock.fill", size: 52)
            Text("Performance is part of INTHEGYM pro")
                .font(.system(size: 20, weight: .bold))
                .multilineTextAlignment(.center)
            Text("Measure your jumps on camera, track them over time, and check every week whether you're fresh or fatigued.")
                .font(.system(size: 15))
                .foregroundStyle(Color.secondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
            // In the card, not pinned: this is the tab's root, and a pinned bar would sit over the
            // tab bar.
            PerformancePrimaryButton(title: "See INTHEGYM pro") {
                viewModel.showPaywall()
            }
            .padding(.top, 4)
            if viewModel.canUnlockForTesting {
                Button("Unlock for testing (emulator)") {
                    viewModel.unlockForTesting()
                }
                .font(.system(size: 14, weight: .medium))
                .tint(Color.secondary)
            }
        }
        .padding(20)
        .performanceCard()
    }
}

