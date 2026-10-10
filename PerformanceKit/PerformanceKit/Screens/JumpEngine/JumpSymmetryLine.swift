//
//  JumpSymmetryLine.swift
//  PerformanceKit
//
//  Created by Findlay Wood on 10/10/2026.
//
import SwiftUI

/// Left against right on one line: "L 24.1 · R 26.3 cm · Left leg 8% weaker",
/// the gap in amber once it is notable (`LimbSymmetry.isNotable`).
struct JumpSymmetryLine: View {

    let symmetry: LimbSymmetry
    var measurement: JumpMeasurement = .cm

    var body: some View {
        HStack(spacing: 6) {
            Text("L \(format(symmetry.left)) · R \(format(symmetry.right)) \(measurement.title)")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color.primary)
            Text("·")
                .foregroundStyle(Color.secondary)
            Text(symmetry.summary)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(symmetry.isNotable ? Color.matteAmber : Color.secondary)
        }
    }

    private func format(_ centimetres: Double) -> String {
        measurement.display(centimetres: centimetres).formatted(.number.precision(.fractionLength(1)))
    }
}
