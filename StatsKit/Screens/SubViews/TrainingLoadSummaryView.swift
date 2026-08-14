//
//  TrainingLoadSummaryView.swift
//  StatsKit
//
//  Created by Findlay Wood on 13/08/2026.
//

import SwiftUI

// MARK: - TrainingLoadSummaryView
/// Both training-load ratios in one card, side by side.
///
/// **One card with two tiles, not one card per metric.** Each metric used to get
/// a full-width card carrying a 40pt number and a four-segment zone bar — around
/// 350pt for the pair, which is the largest block on the home screen and pushed
/// every concrete number below the fold. They are also the content most likely
/// to be empty: `.session` reads `DailyTotal.totalWorkload`, absent from every
/// document written before the aggregation shipped, and neither ratio exists at
/// all until 28 days of history have accumulated. **The biggest thing on the
/// screen should not be the one that stays blank the longest.**
///
/// Side by side the two also *compare*, which is the whole reason there are two
/// of them — a high session ratio beside a flat volume one says the extra work
/// was unloaded, and that reading was impossible when they sat 350pt apart.
struct TrainingLoadSummaryView: View {
    let stats: HomeStats
    let onDetail: (TrainingLoadMetric) -> Void

    private let metrics = TrainingLoadMetric.allCases

    var body: some View {
        SectionContainer(title: "Training Load") {
            HStack(spacing: 0) {
                ForEach(Array(metrics.enumerated()), id: \.element.id) { index, metric in
                    Button { onDetail(metric) } label: {
                        TrainingLoadTile(acwr: stats.acwr(metric), metric: metric)
                    }
                    .buttonStyle(.plain)

                    if index < metrics.count - 1 {
                        Rectangle()
                            .fill(Color(.separator).opacity(0.4))
                            .frame(width: 0.5)
                    }
                }
            }
            .fixedSize(horizontal: false, vertical: true)
        }
    }
}

// MARK: - TrainingLoadTile
/// One metric's ratio, its zone, and what it counted.
///
/// **The number's colour is the zone signal — there is deliberately no zone bar
/// here.** The full-width card carried a four-segment 0–2 scale, which does not
/// survive halving: the Caution band is 10% of the width, around 15pt at this
/// size, too narrow to hold its own label, and the four labels collide.
///
/// That bar also drew its marker at 1.0 whenever the ratio was `nil` — parking a
/// grey pointer in the middle of the green Optimal band directly beneath a label
/// reading "Not enough data", so an absence rendered as a reading. A tile that
/// shows "—" and says why is the honest version. The scale itself lives on the
/// detail screen, where `ACWRProgressionChart` has the width to band it properly.
private struct TrainingLoadTile: View {
    let acwr: ACWR
    let metric: TrainingLoadMetric

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 4) {
                Text(metric.title)
                    .font(.caption).fontWeight(.semibold)
                    .foregroundStyle(.primary)
                    .lineLimit(1)

                Spacer(minLength: 0)

                Image(systemName: "chevron.right")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }

            Text(acwr.formattedRatio)
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundStyle(acwr.zone.color)
                .lineLimit(1)
                .minimumScaleFactor(0.6)

            Text(acwr.zone.label)
                .font(.caption2).fontWeight(.semibold)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .padding(.horizontal, 7)
                .padding(.vertical, 3)
                .background(acwr.zone.color.opacity(0.12))
                .foregroundStyle(acwr.zone.color)
                .clipShape(Capsule())

            // What this ratio counted. With two of them on one card that is the
            // first question, and it is the difference between the numbers.
            Text(metric.subtitle)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
    }
}

// MARK: - Preview
#Preview {
    ScrollView {
        TrainingLoadSummaryView(
            stats: HomeStats(totals: MockDailyTotalsProvider().previewTotals),
            onDetail: { _ in }
        )
        .padding()
    }
    .background(Color.darkColor.ignoresSafeArea())
}
