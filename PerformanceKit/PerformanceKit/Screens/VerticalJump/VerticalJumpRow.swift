//
//  VerticalJumpRow.swift
//  PerformanceKit
//
//  Created by Findlay Wood on 10/10/2026.
//
import SwiftUI

/// A jump: its date small in the corner, its height large in the middle. The
/// legacy home and history screens each wrote this out.
struct VerticalJumpRow: View {

    let jump: VerticalJump
    let measurement: JumpMeasurement

    var body: some View {
        VStack {
            HStack {
                Text(jump.time, format: .dateTime.day().month())
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
            }
            HStack {
                Spacer()
                Text("\(displayedHeight, specifier: "%.2f")\(measurement.title)")
                    .font(.largeTitle.bold())
                    .foregroundColor(Color.darkColor)
                Spacer()
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
