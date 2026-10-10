//
//  BalanceAttemptRow.swift
//  PerformanceKit
//
//  Created by Findlay Wood on 10/10/2026.
//
import SwiftUI

/// One stand slot: its number, its sway (or how long it was held, for a stand
/// stopped early), the best marked, and a remove button.
struct BalanceAttemptRow: View {

    let number: Int
    let attempt: BalanceAttempt?
    let isBest: Bool
    var showsDivider = false
    let onRemove: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                Text("Stand \(number)")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(attempt == nil ? Color.secondary : Color.primary)
                if isBest {
                    Text("BEST")
                        .font(.system(size: 11, weight: .bold))
                        .tracking(0.6)
                        .foregroundStyle(Color.white)
                        .padding(.horizontal, 7)
                        .padding(.vertical, 3)
                        .background(Capsule().fill(Color.darkColor))
                }
                Spacer()
                if let attempt {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("\(attempt.sway.formatted(.number.precision(.fractionLength(1)))) mg")
                            .font(.system(size: 17, weight: .bold))
                            .foregroundStyle(isBest ? Color.darkColor : Color.primary)
                        if !attempt.completed {
                            Text("Foot down at \(Int(attempt.duration)) s")
                                .font(.system(size: 12))
                                .foregroundStyle(Color.matteAmber)
                        }
                    }
                    Button(action: onRemove) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 18))
                            .foregroundStyle(Color(.tertiaryLabel))
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Remove stand \(number)")
                } else {
                    Text("Not recorded")
                        .font(.system(size: 14))
                        .foregroundStyle(Color(.tertiaryLabel))
                }
            }
            .padding(.horizontal, 16)
            .frame(minHeight: 56)
            if showsDivider {
                Divider().padding(.leading, 16)
            }
        }
    }
}
