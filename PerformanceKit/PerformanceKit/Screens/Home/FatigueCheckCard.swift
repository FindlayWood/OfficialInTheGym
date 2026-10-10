//
//  FatigueCheckCard.swift
//  PerformanceKit
//
//  Created by Findlay Wood on 10/10/2026.
//
import SwiftUI

/// The dashboard's lead card: this week's fatigue check. Its result as a
/// percentage of the athlete's 8-week best, in its zone's colour, with the
/// zone bar and a line of advice; or calibrating, with how many checks to go;
/// or an invitation to take the first. The foot says when the next is due.
///
/// **The card carries the action that starts a check** (`onStart`): the
/// primary button when one is due, a quiet "Check again" otherwise, and
/// nothing on someone else's centre. It used to be a button pinned to the
/// bottom of the tab, where it sat on top of the tab bar; the tab's root has
/// no pinned bar now.
struct FatigueCheckCard: View {

    let check: FatigueCheck
    let isDue: Bool
    var onStart: (() -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            content
            Divider()
            dueLine
            if let onStart {
                if isDue {
                    PerformancePrimaryButton(title: check.latest == nil ? "Take your first check" : "Start this week's check", action: onStart)
                        .padding(.top, 4)
                } else {
                    Button("Check again", action: onStart)
                        .font(.system(size: 15, weight: .semibold))
                        .tint(Color.darkColor)
                        .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(16)
        .performanceCard()
        .overlay {
            if case .result(_, let zone, _) = check.status {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(zone.color, lineWidth: 1.5)
            }
        }
    }

    @ViewBuilder
    private var content: some View {
        switch check.status {
        case .none:
            HStack(alignment: .top, spacing: 14) {
                PerformanceIconTile(systemName: "bolt.heart.fill")
                VStack(alignment: .leading, spacing: 4) {
                    Text("Take your first check")
                        .font(.system(size: 17, weight: .semibold))
                    Text("Three CMJs, once a week. After three checks, each one is measured against your best of the last 8 weeks.")
                        .font(.system(size: 14))
                        .foregroundStyle(Color.secondary)
                }
            }

        case .calibrating(let sessions, let needed):
            VStack(alignment: .leading, spacing: 8) {
                Text("Calibrating")
                    .font(.system(size: 17, weight: .semibold))
                HStack(spacing: 6) {
                    ForEach(0..<needed, id: \.self) { index in
                        Capsule()
                            .fill(index < sessions ? Color.darkColor : Color(.tertiarySystemFill))
                            .frame(height: 6)
                    }
                }
                Text("\(sessions) of \(needed) checks. Your result appears once there's enough to compare against.")
                    .font(.system(size: 14))
                    .foregroundStyle(Color.secondary)
            }

        case .result(let fraction, let zone, let reference):
            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .firstTextBaseline) {
                    Text("\(Int((fraction * 100).rounded()))%")
                        .font(.system(size: 44, weight: .bold))
                        .foregroundStyle(zone.color)
                    Spacer()
                    Text(check.isNewBest ? "New best" : zone.title)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(Color.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Capsule().fill(zone.color))
                }
                if let referenceHeight = reference.best?.height {
                    Text("of your 8-week best, \(referenceHeight, specifier: "%.1f") cm on \(reference.date.formatted(.dateTime.day().month(.abbreviated)))")
                        .font(.system(size: 13))
                        .foregroundStyle(Color.secondary)
                }
                FatigueZoneBar(fraction: fraction)
                    .padding(.vertical, 4)
                Text(zone.advice)
                    .font(.system(size: 14, weight: .medium))
            }
        }
    }

    private var dueLine: some View {
        HStack(spacing: 6) {
            Image(systemName: isDue ? "exclamationmark.circle.fill" : "calendar")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(isDue ? Color.matteAmber : Color.secondary)
            if isDue {
                Text(check.latest == nil ? "Due now" : "This week's check is due")
                    .font(.system(size: 13, weight: .semibold))
            } else if let nextDue = check.nextDue {
                Text("Next check due \(nextDue.formatted(.dateTime.weekday(.wide).day().month(.abbreviated)))")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Color.secondary)
            }
            Spacer()
            if let latest = check.latest {
                Text("Last \(latest.date.formatted(.dateTime.day().month(.abbreviated)))")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.secondary)
            }
        }
    }
}
