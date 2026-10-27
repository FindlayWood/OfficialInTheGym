//
//  StatsTopLiftCard.swift
//  StatsKit
//
//  Created by Findlay Wood on 27/10/2026.
//

import SwiftUI

/// The free view's one lift: name, best set in the last four weeks, and the change from the four
/// before.
///
/// **The change is not colour-coded up-good / down-bad**, for the reason the home chart's change
/// chip is not: a lighter month may be a deload, and painting it red would judge it. Direction
/// only. The row matches `ExerciseRowContent` — a solid 44pt `darkColor` tile, the anchor every
/// exercise row in STATS carries — but is not tappable: the detail screen is pro.
struct StatsTopLiftCard: View {
    let lift: StatsTopLift

    var body: some View {
        SectionContainer(title: "Your top lift") {
            HStack(spacing: 12) {
                Image(systemName: "dumbbell.fill")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(Color.white)
                    .frame(width: 44, height: 44)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Color.darkColor)
                    )

                VStack(alignment: .leading, spacing: 2) {
                    Text(lift.name)
                        .font(.system(size: 16, weight: .semibold))
                        .lineLimit(1)
                    Text("Best set, last 4 weeks")
                        .font(.system(size: 13))
                        .foregroundStyle(.secondary)
                }

                Spacer(minLength: 8)

                VStack(alignment: .trailing, spacing: 4) {
                    Text(Self.kilograms(lift.recentBest))
                        .font(.system(size: 17, weight: .bold))
                    if let change = lift.change {
                        changeChip(change)
                    }
                }
            }
            .padding(16)
        }
    }

    private func changeChip(_ change: Double) -> some View {
        HStack(spacing: 3) {
            if change != 0 {
                Image(systemName: change > 0 ? "arrow.up" : "arrow.down")
                    .font(.system(size: 10, weight: .bold))
            }
            Text(change == 0 ? "Same as before" : Self.kilograms(abs(change)))
                .font(.system(size: 12, weight: .semibold))
        }
        .foregroundStyle(.secondary)
        .padding(.horizontal, 8)
        .padding(.vertical, 3)
        .background(Capsule().fill(Color(.tertiarySystemFill)))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(change == 0
            ? "Same as the four weeks before"
            : "\(change > 0 ? "Up" : "Down") \(Self.kilograms(abs(change))) on the four weeks before")
    }

    /// Whole kilograms print without a decimal; 62.5 keeps its half.
    static func kilograms(_ value: Double) -> String {
        value.rounded() == value
            ? String(format: "%.0f kg", value)
            : String(format: "%.1f kg", value)
    }
}
