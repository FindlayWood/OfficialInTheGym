//
//  InjuriesSummaryView.swift
//  StatsKit
//
//  Created by Findlay Wood on 10/11/2026.
//

import SwiftUI

/// The home's injuries: current ones first, then cleared ones, each opening its page.
///
/// **Drawn only when there is something logged.** An empty card asking for injuries would be
/// a prompt to get hurt; logging lives in MyDay's check-in, where the question is asked.
struct InjuriesSummaryView: View {

    let injuries: [StatsInjury]
    let onInjuryTapped: (StatsInjury) -> Void

    /// Current first, then the most recent start.
    private var ordered: [StatsInjury] {
        injuries.sorted { lhs, rhs in
            lhs.isCurrent != rhs.isCurrent ? lhs.isCurrent : lhs.startedOn > rhs.startedOn
        }
        .prefix(5)
        .map { $0 }
    }

    var body: some View {
        SectionContainer(title: "Injuries") {
            VStack(spacing: 0) {
                ForEach(Array(ordered.enumerated()), id: \.element.id) { index, injury in
                    Button { onInjuryTapped(injury) } label: {
                        row(injury)
                    }
                    .buttonStyle(.plain)
                    if index < ordered.count - 1 {
                        Divider().padding(.leading, 70)
                    }
                }
            }
        }
    }

    private func row(_ injury: StatsInjury) -> some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(injury.isCurrent ? Color.matteRed : Color(.tertiarySystemGroupedBackground))
                    .frame(width: 44, height: 44)
                Image(systemName: injury.isCurrent ? "bandage.fill" : "checkmark")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(injury.isCurrent ? Color.white : Color.secondary)
            }
            VStack(alignment: .leading, spacing: 3) {
                Text(injury.title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color.primary)
                Text(InjuryDayFormat.span(of: injury))
                    .font(.system(size: 13))
                    .foregroundStyle(Color.secondary)
            }
            Spacer(minLength: 8)
            if injury.isCurrent, let latest = injury.latestCheckIn {
                Text("Pain \(latest.pain)")
                    .font(.system(size: 12, weight: .semibold))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(InjuryPainColor.color(for: latest.pain).opacity(0.14))
                    .foregroundStyle(InjuryPainColor.color(for: latest.pain))
                    .clipShape(Capsule())
            }
            Image(systemName: "chevron.right")
                .font(.caption2)
                .foregroundStyle(.tertiary)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .contentShape(Rectangle())
    }
}
