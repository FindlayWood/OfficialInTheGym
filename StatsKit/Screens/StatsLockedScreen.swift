//
//  StatsLockedScreen.swift
//  StatsKit
//
//  Created by Findlay Wood on 12/10/2026.
//

import SwiftUI

/// What the STATS tab shows without INTHEGYM pro: the real home screen, blurred, drawn from
/// sample data, with the way to the paywall over it.
///
/// **A preview, not a description.** The tab's value is its shape — the weekly chart, the activity
/// grid, the two load ratios — and a paragraph cannot show a shape. So the locked screen renders the
/// actual `HomeScreenContent` from `MockDailyTotalsProvider`, blurred until it reads as charts
/// rather than numbers, so nothing on it can be mistaken for the user's own training.
///
/// The card's promise is true and worth saying: everything the user logs is already counted
/// (the raw logs and `DailyTotal`s are written whether or not they have pro), so subscribing shows
/// their whole history, not a tab that starts empty.
struct StatsLockedScreen: View {

    @ObservedObject var viewModel: StatsGateViewModel

    /// Generated once: the mock is random, and regenerating it on every render would shimmer.
    private static let previewTotals = MockDailyTotalsProvider().previewTotals

    var body: some View {
        VStack(spacing: 0) {
            header

            ZStack {
                ScrollView {
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
                    .padding()
                }
                .scrollDisabled(true)
                .blur(radius: 10)
                .allowsHitTesting(false)
                .accessibilityHidden(true)

                lockCard
                    .padding(.horizontal, 24)
            }
            .clipped()
        }
        .background {
            Color.pageColor.ignoresSafeArea()
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack(alignment: .center) {
            Text("Stats")
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(Color.darkColor)
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background {
            Color(UIColor.systemBackground).ignoresSafeArea()
        }
    }

    // MARK: - Lock Card

    private var lockCard: some View {
        VStack(spacing: 14) {
            Image(systemName: "lock.fill")
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(Color.white)
                .frame(width: 52, height: 52)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color.darkColor)
                )

            Text("Stats are part of INTHEGYM pro")
                .font(.system(size: 20, weight: .bold))
                .multilineTextAlignment(.center)

            Text("Weekly volume, streaks, training load and progress for every exercise. Everything you log is already being counted, so your whole history is here the moment you subscribe.")
                .font(.system(size: 15))
                .foregroundStyle(Color.secondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)

            Button {
                viewModel.showPaywall()
            } label: {
                Text("See INTHEGYM pro")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(Color.darkColor)
                    )
            }
            .padding(.top, 4)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(UIColor.secondarySystemGroupedBackground))
        )
    }
}

#Preview {
    StatsLockedScreen(viewModel: StatsGateViewModel(proAccess: PreviewStatsProAccess(hasUnlockedPro: false)))
}
