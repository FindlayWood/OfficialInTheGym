//
//  TrainingBalanceSummaryView.swift
//  StatsKit
//
//  Created by Findlay Wood on 13/08/2026.
//

import SwiftUI

// MARK: - TrainingBalanceSummaryView
/// The top muscle groups by volume, drawn as ranked bars.
///
/// **This card used to do the ranking and then throw it away.** It computed
/// `topMuscleGroups` — an ordered distribution, the one thing on this screen
/// whose data is inherently a picture — and rendered a 50pt icon tile beside a
/// sentence about it. "Balance" is a comparison, and a comparison wants a shape;
/// five bars say which group leads and by how much in the time it takes to
/// glance at them, where the sentence had to be read.
///
/// The sentence is kept underneath, because it says the thing the bars cannot:
/// what to *do* about the shape. It is a caption now rather than the content.
///
/// **Bars are `Color.darkColor` at descending opacity, not five different
/// colours.** The opacity ramp *is* the ranking; a five-colour palette would add
/// a second visual dimension carrying no information, and the muscle-group
/// colours would be invented here rather than meaning anything — `MuscleGroup`
/// holds only an `id` and a `name`.
struct TrainingBalanceSummaryView: View {
    let balanceData: TrainingBalanceData
    let muscleGroups: [MuscleGroup]
    let onDetail: () -> Void

    private let maximumBars = 5

    private var bars: [(name: String, volume: Double, share: Double)] {
        let total = balanceData.totalVolume
        guard total > 0 else { return [] }

        return balanceData.topMuscleGroups
            .prefix(maximumBars)
            .map { entry in
                (
                    name: name(for: entry.muscleGroup),
                    volume: entry.volume,
                    share: entry.volume / total
                )
            }
    }

    var body: some View {
        SectionContainer(title: "Training Balance") {
            Button(action: onDetail) {
                VStack(alignment: .leading, spacing: 14) {
                    header

                    if bars.isEmpty {
                        Text("No training data for this period.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    } else {
                        VStack(spacing: 9) {
                            ForEach(Array(bars.enumerated()), id: \.offset) { index, bar in
                                MuscleGroupShareRow(
                                    name: bar.name,
                                    share: bar.share,
                                    // Scaled against the leader, not against the
                                    // total: shares of a five-way split are all
                                    // short bars, and the card is about which is
                                    // biggest relative to the rest.
                                    fraction: bar.volume / (bars.first?.volume ?? 1),
                                    rank: index
                                )
                            }
                        }

                        Text(summaryMessage)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .padding(16)
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack(spacing: 6) {
            Text("Muscle Group Balance")
                .font(.subheadline).fontWeight(.medium)
                .foregroundStyle(.primary)

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
    }

    // MARK: - Copy

    private func name(for id: String) -> String {
        muscleGroups.first(where: { $0.id == id })?.name ?? "Unknown"
    }

    private var summaryMessage: String {
        let groups = balanceData.topMuscleGroups
        guard let leader = groups.first else {
            return "No training data for this period."
        }

        let topName = name(for: leader.muscleGroup)

        if groups.count == 1 {
            return "Only \(topName) trained this period. Try adding more variety."
        }

        let ratio = groups[1].volume > 0 ? leader.volume / groups[1].volume : 0

        if ratio > 3 {
            return "\(topName) is dominating your volume. Consider balancing across more groups."
        } else if groups.count >= 4 {
            return "Training \(groups.count) muscle groups with good distribution."
        } else {
            return "Training \(groups.count) muscle groups this period."
        }
    }
}

// MARK: - MuscleGroupShareRow
/// One group's share, on a single line: name, bar, percentage.
///
/// **Not `TrainingBalanceScreen`'s `MuscleGroupBar`, deliberately.** That one
/// stacks a name-and-volume header over a full-width bar — right on a detail
/// screen with room to spend, but about 28pt a group, which is 140pt for five
/// here before the header and the caption. This is a summary. It also scales
/// against the leading group rather than the total, because five shares of one
/// split are all short bars and the question this card answers is which is
/// *biggest*. The percentages both draw come from `TrainingBalanceData` — the
/// arithmetic is shared even though the layouts are not.
private struct MuscleGroupShareRow: View {
    let name: String
    let share: Double
    let fraction: Double
    let rank: Int

    var body: some View {
        HStack(spacing: 10) {
            Text(name)
                .font(.caption)
                .foregroundStyle(.primary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .frame(width: 76, alignment: .leading)

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(.tertiarySystemFill))

                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.darkColor.opacity(opacity))
                        // A group with a real but tiny share still gets a
                        // visible stub rather than an empty track, which would
                        // read as "not trained".
                        .frame(width: max(4, geo.size.width * CGFloat(min(max(fraction, 0), 1))))
                }
            }
            .frame(height: 10)

            Text(String(format: "%.0f%%", share * 100))
                .font(.caption2).fontWeight(.medium)
                .foregroundStyle(.secondary)
                .frame(width: 32, alignment: .trailing)
        }
    }

    private var opacity: Double {
        max(0.35, 1.0 - Double(rank) * 0.16)
    }
}
