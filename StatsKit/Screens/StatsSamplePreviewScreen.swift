//
//  StatsSamplePreviewScreen.swift
//  StatsKit
//
//  Created by Findlay Wood on 18/10/2026.
//

import SwiftUI

/// The STATS home on sample data, unblurred, for someone who has not signed up yet.
///
/// `StatsProTeaser` draws the same chart and load card blurred, because there it sits on a
/// signed-in user's tab, under their own week, and must never pass for their own training. Before signup there is no own
/// training to confuse it with, so here it is legible — the point is to show what logging turns
/// into. **It is labelled as sample data and as pro, at the top**: a preview that let someone sign
/// up expecting free stats would end at the paywall and read as a bait-and-switch.
///
/// The chart's metric toggle works; the drill-downs do nothing, since every detail screen would
/// need its own sample loader for little gain.
struct StatsSamplePreviewScreen: View {

    /// Generated once: the mock is random, and regenerating it on every render would shimmer.
    private static let previewTotals = MockDailyTotalsProvider().previewTotals

    var onBack: (() -> Void)?

    var body: some View {
        VStack(spacing: 0) {
            StatsSamplePreviewNavBar(title: "Stats", onBack: onBack)
            content
        }
    }

    private var content: some View {
        ScrollView {
            VStack(spacing: 16) {
                StatsSamplePreviewBanner()

                HomeScreenContent(
                    totals: Self.previewTotals,
                    exercises: ExerciseStats.mocks,
                    muscleGroups: [],
                    onSeeAllExercises: {},
                    onACWRDetail: { _ in },
                    onExerciseTapped: { _ in },
                    onBodyMetricsDetail: {},
                    onTrainingBalanceTapped: {}
                )
            }
            .padding()
        }
        .background {
            Color.pageColor.ignoresSafeArea()
        }
    }
}

#Preview {
    StatsSamplePreviewScreen()
}
