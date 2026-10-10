//
//  BalanceSymmetryLine.swift
//  PerformanceKit
//
//  Created by Findlay Wood on 10/10/2026.
//
import SwiftUI

/// Left against right sway on one line: "L 12.4 · R 15.1 mg · Right leg 18%
/// weaker", the gap in amber once notable. Lower sway is the better leg.
struct BalanceSymmetryLine: View {

    let symmetry: LimbSymmetry

    var body: some View {
        HStack(spacing: 6) {
            Text("L \(format(symmetry.left)) · R \(format(symmetry.right)) mg")
                .font(.system(size: 14, weight: .semibold))
            Text("·")
                .foregroundStyle(Color.secondary)
            Text(symmetry.summary)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(symmetry.isNotable ? Color.matteAmber : Color.secondary)
        }
    }

    private func format(_ value: Double) -> String {
        value.formatted(.number.precision(.fractionLength(1)))
    }
}
