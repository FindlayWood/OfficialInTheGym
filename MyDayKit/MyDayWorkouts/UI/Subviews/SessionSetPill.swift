//
//  SessionSetPill.swift
//  MyDayKit
//
//  Created by Findlay Wood on 27/06/2026.
//

import SwiftUI

struct SessionSetPill: View {

    let index: Int
    let set: WorkoutSetModel
    let isLogged: Bool
    let isDisabled: Bool
    let onTap: () -> Void

    var body: some View {
        VStack(spacing: 4) {
            Text("Set \(index + 1)")
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(isLogged ? Color.white.opacity(0.7) : Color.secondary)
                .textCase(.uppercase)
                .tracking(0.5)

            if let reps = set.reps {
                HStack(alignment: .lastTextBaseline, spacing: 2) {
                    Text("\(reps)")
                        .font(.system(size: 16, weight: .bold))
                    Text("reps")
                        .font(.system(size: 10))
                }
                .foregroundStyle(isLogged ? Color.white : Color.primary)
            }

            if let weight = set.weight {
                let unit = set.weightUnit?.rawValue ?? "kg"
                Text(formatWeight(weight, unit: unit))
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(isLogged ? Color.white.opacity(0.85) : Color.darkColor)
            }

            if let time = set.time {
                Text(formatTime(time))
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(isLogged ? Color.white : Color.primary)
            }

            if let dist = set.distance, let unit = set.distanceUnit {
                Text("\(formatValue(dist))\(unit.rawValue)")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(isLogged ? Color.white.opacity(0.85) : Color.darkColor)
            }

            Spacer(minLength: 4)

            Image(systemName: isLogged ? "checkmark.circle.fill" : "circle")
                .font(.system(size: 22, weight: .medium))
                .foregroundStyle(isLogged ? Color.white : Color.secondary.opacity(isDisabled ? 0.25 : 0.5))
        }
        .frame(width: 72, height: 88)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(isLogged ? Color.darkColor : Color(UIColor.secondarySystemBackground))
        )
        .contentShape(Rectangle())
        .onTapGesture { if !isDisabled { onTap() } }
        .animation(.easeInOut(duration: 0.2), value: isLogged)
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

// MARK: - Preview

#Preview {
    HStack(spacing: 8) {
        SessionSetPill(
            index: 0,
            set: WorkoutSetModel(id: "s1", orderIndex: 0, reps: 8, weight: 80, weightUnit: .kg),
            isLogged: false,
            isDisabled: true,
            onTap: {}
        )
        SessionSetPill(
            index: 1,
            set: WorkoutSetModel(id: "s2", orderIndex: 1, reps: 8, weight: 80, weightUnit: .kg),
            isLogged: true,
            isDisabled: false,
            onTap: {}
        )
        SessionSetPill(
            index: 2,
            set: WorkoutSetModel(id: "s3", orderIndex: 2, time: 60),
            isLogged: false,
            isDisabled: false,
            onTap: {}
        )
    }
    .padding(20)
    .background(Color(UIColor.systemGroupedBackground))
}
