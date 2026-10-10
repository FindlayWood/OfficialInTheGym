//
//  JumpPowerLine.swift
//  PerformanceKit
//
//  Created by Findlay Wood on 10/10/2026.
//
import SwiftUI

/// Peak power and power per kilogram on one line, "2,950 W · 39.3 W/kg",
/// marked as an estimate because it is one.
struct JumpPowerLine: View {

    let power: JumpPower

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "bolt.fill")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Color.darkColor)
            Text("\(power.watts.formatted(.number.precision(.fractionLength(0)))) W · \(power.wattsPerKilogram.formatted(.number.precision(.fractionLength(1)))) W/kg")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color.primary)
            Text("est.")
                .font(.system(size: 12))
                .foregroundStyle(Color.secondary)
        }
    }
}
