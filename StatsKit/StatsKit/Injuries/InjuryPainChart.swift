//
//  InjuryPainChart.swift
//  StatsKit
//
//  Created by Findlay Wood on 10/11/2026.
//

import SwiftUI

/// Pain across an injury's life: a bar for each day it lasted, coloured by `InjuryPainColor`,
/// with a marker under each bar for how it changed training. Hand-built, as every chart is.
///
/// **A day with no rating draws no bar, not a zero.** "Didn't rate it" is not "no pain", and a
/// zero would make an injury look better on the days it was not looked at.
struct InjuryPainChart: View {

    let injury: StatsInjury

    private var days: [String] { injury.dayKeys() }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            GeometryReader { geo in
                let slot = geo.size.width / CGFloat(max(days.count, 1))
                let barWidth = max(2, min(14, slot * 0.7))
                HStack(alignment: .bottom, spacing: 0) {
                    ForEach(days, id: \.self) { day in
                        VStack(spacing: 4) {
                            Spacer(minLength: 0)
                            if let checkIn = injury.checkIns[day] {
                                RoundedRectangle(cornerRadius: 3)
                                    .fill(InjuryPainColor.color(for: checkIn.pain))
                                    .frame(width: barWidth, height: max(3, (geo.size.height - 14) * CGFloat(checkIn.pain) / 10))
                                impactMarker(checkIn.impact)
                                    .frame(width: barWidth, height: 6)
                            } else {
                                Color.clear.frame(width: barWidth, height: 6)
                            }
                        }
                        .frame(width: slot)
                    }
                }
            }
            .frame(height: 120)

            HStack {
                Text(InjuryDayFormat.short(days.first ?? injury.startedOn))
                Spacer()
                Text(injury.isCurrent ? "Today" : InjuryDayFormat.short(days.last ?? injury.startedOn))
            }
            .font(.system(size: 10))
            .foregroundStyle(.secondary)

            legend
        }
        .padding(16)
    }

    @ViewBuilder
    private func impactMarker(_ impact: StatsInjuryImpact) -> some View {
        switch impact {
        case .none:
            Color.clear
        case .modified:
            Capsule().fill(Color.secondary.opacity(0.45))
        case .stopped:
            Capsule().fill(Color.primary)
        }
    }

    private var legend: some View {
        let counts = Dictionary(grouping: injury.checkIns.values, by: \.impact).mapValues(\.count)
        return HStack(spacing: 14) {
            ForEach(StatsInjuryImpact.allCases, id: \.self) { impact in
                HStack(spacing: 5) {
                    impactMarker(impact)
                        .frame(width: 10, height: 6)
                        .overlay(impact == .none ? Capsule().stroke(Color.secondary.opacity(0.4), lineWidth: 1) : nil)
                    Text("\(impact.title) \(counts[impact] ?? 0)")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}
