//
//  MyDayTemplateSetPill.swift
//  MyDayKit
//
//  Created by Findlay Wood on 27/06/2026.
//

import SwiftUI

struct MyDayTemplateSetPill: View {

    let index: Int
    let set: WorkoutSetModel

    var body: some View {
        VStack(spacing: 4) {
            Text("Set \(index + 1)")
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(Color.secondary)
                .textCase(.uppercase)
                .tracking(0.5)

            if let reps = set.reps {
                HStack(alignment: .lastTextBaseline, spacing: 2) {
                    Text("\(reps)")
                        .font(.system(size: 16, weight: .bold))
                    Text("reps")
                        .font(.system(size: 10))
                }
                .foregroundStyle(Color.primary)
            }

            if let weight = set.weight {
                let unit = set.weightUnit?.rawValue ?? "kg"
                Text(formatWeight(weight, unit: unit))
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color.darkColor)
            }

            if let time = set.time {
                Text(formatTime(time))
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(Color.primary)
            }

            if let dist = set.distance, let unit = set.distanceUnit {
                Text("\(formatValue(dist))\(unit.rawValue)")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color.darkColor)
            }
        }
        .frame(width: 72, height: 72)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color(UIColor.secondarySystemBackground))
        )
    }

    private func formatWeight(_ w: Double, unit: String) -> String {
        w.truncatingRemainder(dividingBy: 1) == 0 ? "\(Int(w))\(unit)" : "\(w)\(unit)"
    }

    private func formatTime(_ s: Int) -> String {
        let m = s / 60; let sec = s % 60
        return m > 0 ? "\(m)m\(sec)s" : "\(sec)s"
    }

    private func formatValue(_ v: Double) -> String {
        v.truncatingRemainder(dividingBy: 1) == 0 ? "\(Int(v))" : "\(v)"
    }
}
