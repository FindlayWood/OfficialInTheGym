//
//  VerticalJumpRow.swift
//  PerformanceKit
//
//  Created by Findlay Wood on 10/10/2026.
//
import SwiftUI

/// One saved jump in the history: its date, then its height in the chosen
/// unit, on one line, inside a card of joined rows.
struct VerticalJumpRow: View {

    let jump: VerticalJump
    let measurement: JumpMeasurement
    var showsDivider = false

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text(jump.time, format: .dateTime.day().month(.abbreviated).year())
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(Color.primary)
                Spacer()
                Text("\(displayedHeight, specifier: "%.1f") \(measurement.title)")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(Color.darkColor)
            }
            .padding(.horizontal, 16)
            .frame(minHeight: 52)
            if showsDivider {
                Divider().padding(.leading, 16)
            }
        }
    }

    private var displayedHeight: Double {
        switch measurement {
        case .cm: jump.height
        case .inches: JumpMeasurement.inches(fromCentimetres: jump.height)
        }
    }
}
