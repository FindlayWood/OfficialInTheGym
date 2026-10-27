//
//  StatsFreeScreen.swift
//  StatsKit
//
//  Created by Findlay Wood on 27/10/2026.
//

import SwiftUI

/// The STATS tab without INTHEGYM pro: the user's own week, streak and top lift, then what pro
/// adds (`StatsProTeaser`).
///
/// It replaced `StatsLockedScreen`, which was a blurred sample of the whole home under a lock
/// card. That kept the one thing that sells pro — the user's own numbers — away from exactly the
/// people who had not paid. See `StatsFreeSummary` for what is free and why. Nothing here taps
/// through to a pro screen: every detail is reached from the pro home.
struct StatsFreeScreen: View {

    @ObservedObject var viewModel: StatsFreeViewModel

    var body: some View {
        VStack(spacing: 0) {
            header

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    content

                    StatsProTeaser(onShowPaywall: viewModel.showPaywall)
                }
                .padding()
            }
        }
        .background {
            Color.pageColor.ignoresSafeArea()
        }
        .task { await viewModel.load() }
    }

    // MARK: - Content

    @ViewBuilder
    private var content: some View {
        if let summary = viewModel.summary {
            StatsThisWeekCard(summary: summary)

            SectionContainer(title: "Streak") {
                StreakRow(streak: summary.streak)
            }

            if let lift = viewModel.topLift {
                StatsTopLiftCard(lift: lift)
            }
        } else if viewModel.state == .failed {
            SectionContainer(title: "This week") {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Couldn't load your week")
                        .font(.system(size: 17, weight: .semibold))
                    Text("Check your connection. It'll try again next time you open Stats.")
                        .font(.system(size: 13))
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(16)
            }
        } else {
            SectionContainer(title: "This week") {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .frame(height: 160)
            }
        }
    }

    // MARK: - Header

    /// No "pro" wordmark — this screen is only drawn without it.
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
}

#Preview {
    StatsFreeScreen(
        viewModel: StatsFreeViewModel(
            loader: MockDailyTotalsProvider(),
            exerciseDailyStatsLoader: MockExerciseDailyStatsProvider()
        )
    )
}
