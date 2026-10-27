//
//  StatsProTeaser.swift
//  StatsKit
//
//  Created by Findlay Wood on 27/10/2026.
//

import SwiftUI

/// What pro adds, under the free view: the home's chart and training-load card drawn from sample
/// data and blurred, with the way to the paywall over them.
///
/// **A preview, not a description** — the reason the old locked screen drew the real home rather
/// than a paragraph still holds: a tab sells a shape. It replaced that screen, which was the whole
/// tab; this is the bottom of it.
///
/// **It says SAMPLE DATA in its header.** The locked screen relied on blur alone to stop anyone
/// mistaking the sample for their own training, and could, because nothing real was near it. Here
/// it sits directly under the user's own numbers, so it has to say so in words.
struct StatsProTeaser: View {

    let onShowPaywall: () -> Void

    /// Generated once: the mock is random, and regenerating it on every render would shimmer.
    private static let sampleTotals = MockDailyTotalsProvider().previewTotals

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header

            ZStack {
                VStack(alignment: .leading, spacing: 20) {
                    TrainingChartSection(totals: Self.sampleTotals)
                    TrainingLoadSummaryView(stats: HomeStats(totals: Self.sampleTotals), onDetail: { _ in })
                }
                .blur(radius: 10)
                .allowsHitTesting(false)
                .accessibilityHidden(true)

                lockCard
                    .padding(.horizontal, 8)
            }
        }
    }

    // MARK: - Header

    /// Styled as a `SectionContainer` header — on the page, so white.
    private var header: some View {
        HStack(spacing: 8) {
            Text("With pro")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(.white)
                .textCase(.uppercase)
                .tracking(0.5)
            Spacer()
            Text("SAMPLE DATA")
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(.white.opacity(0.8))
                .tracking(1.2)
        }
        .padding(.bottom, 8)
        .padding(.horizontal, 2)
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

            Text("See your full stats")
                .font(.system(size: 20, weight: .bold))
                .multilineTextAlignment(.center)

            Text("Twelve weeks of training, your training load, training balance and progress for every exercise. Everything you log is already being counted, so your whole history is here the moment you subscribe.")
                .font(.system(size: 15))
                .foregroundStyle(Color.secondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)

            Button(action: onShowPaywall) {
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
