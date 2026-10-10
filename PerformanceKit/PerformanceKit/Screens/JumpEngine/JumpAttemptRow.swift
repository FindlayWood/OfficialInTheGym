//
//  JumpAttemptRow.swift
//  PerformanceKit
//
//  Created by Findlay Wood on 10/10/2026.
//
import SwiftUI

/// One attempt slot in a session: its number, its height once measured (the
/// best in `darkColor` with a BEST badge), and a button to remove it so it
/// can be recorded again. An empty slot says so rather than vanishing, so the
/// three-attempt shape of the test is visible from the start.
struct JumpAttemptRow: View {

    let number: Int
    let attempt: JumpAttempt?
    let isBest: Bool
    let measurement: JumpMeasurement
    var showsDivider = false
    let onRemove: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                Text("Attempt \(number)")
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
                    Text("\(measurement.display(centimetres: attempt.height), specifier: "%.1f") \(measurement.title)")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(isBest ? Color.darkColor : Color.primary)
                    Button(action: onRemove) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 18))
                            .foregroundStyle(Color(.tertiaryLabel))
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Remove attempt \(number)")
                } else {
                    Text("Not recorded")
                        .font(.system(size: 14))
                        .foregroundStyle(Color(.tertiaryLabel))
                }
            }
            .padding(.horizontal, 16)
            .frame(minHeight: 52)
            if showsDivider {
                Divider().padding(.leading, 16)
            }
        }
    }
}
