//
//  PerformanceSamplePreviewScreen.swift
//  PerformanceKit
//
//  Created by Findlay Wood on 18/10/2026.
//
import SwiftUI

/// The PERFORMANCE dashboard on sample sessions, unblurred, for someone who has not signed up yet.
///
/// The same decision as StatsKit's `StatsSamplePreviewScreen`: `PerformanceLockedScreen` blurs
/// this dashboard because it sits on a signed-in user's tab, but before signup there are no tests
/// of their own to confuse it with. `PreviewJumpTestSessionsLoader` has fixed numbers, so the
/// fatigue card reads the same on every visit. **Labelled as sample data and as pro, pinned above
/// the dashboard**, and `canRecord: false`, so there is no start button to tap through to a camera.
struct PerformanceSamplePreviewScreen: View {

    @StateObject private var preview = PerformanceDashboardViewModel(
        loader: PreviewJumpTestSessionsLoader(),
        canRecord: false
    )

    var onBack: (() -> Void)?

    var body: some View {
        PerformanceHomeScreen(viewModel: preview)
            .safeAreaInset(edge: .top, spacing: 0) {
                VStack(spacing: 0) {
                    PerformanceSamplePreviewNavBar(title: "Performance", onBack: onBack)
                    PerformanceSamplePreviewBanner()
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                }
                .background(Color(.systemBackground))
            }
    }
}

#Preview {
    PerformanceSamplePreviewScreen()
}
