//
//  WeightTrendLine.swift
//  ProfileKit
//
//  Created by Findlay Wood on 03/10/2026.
//
import SwiftUI

/// The weight log as a line, hand-built (no Swift Charts), oldest on the left.
///
/// **A line, where the STATS tab uses bars.** A weekly training total is a
/// discrete sum and a rest week really is zero, so a line between two weeks
/// would invent values. Bodyweight is continuous: it existed between two
/// weigh-ins, and the line between them is a fair reading of it. The x-axis is
/// **time, not entry index**, so a month without logging is a long flat
/// stretch, not two readings sitting side by side as if they were a day apart.
///
/// The y-axis spans the log's own range with a little padding, because a
/// bodyweight trend lives in the last few kilograms. Zero-based, every line
/// would be flat.
struct WeightTrendLine: View {

    /// Newest first, as the view model holds them.
    let entries: [WeightEntry]
    let unit: ProfileWeightUnit

    var body: some View {
        let points = chronological
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(unit.display(kilograms: maxKilograms))
                Spacer()
            }
            GeometryReader { geometry in
                ZStack {
                    path(in: geometry.size, points: points)
                        .stroke(Color.darkColor, style: StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round))
                    if let last = points.last {
                        Circle()
                            .fill(Color.darkColor)
                            .frame(width: 8, height: 8)
                            .position(position(of: last, in: geometry.size))
                    }
                }
            }
            .frame(height: 90)
            HStack {
                Text(unit.display(kilograms: minKilograms))
                Spacer()
                if let first = points.first, let last = points.last {
                    Text("\(WeightDay.displayFormatter.string(from: first.date)) – \(WeightDay.displayFormatter.string(from: last.date))")
                }
            }
        }
        .font(.system(size: 11, weight: .medium))
        .foregroundStyle(Color.secondary)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Weight trend from \(unit.display(kilograms: chronological.first?.weightKilograms ?? 0)) to \(unit.display(kilograms: chronological.last?.weightKilograms ?? 0))")
    }

    private var chronological: [WeightEntry] { entries.reversed() }

    private var minKilograms: Double { entries.map(\.weightKilograms).min() ?? 0 }
    private var maxKilograms: Double { entries.map(\.weightKilograms).max() ?? 0 }

    private func path(in size: CGSize, points: [WeightEntry]) -> Path {
        Path { path in
            for (index, entry) in points.enumerated() {
                let point = position(of: entry, in: size)
                if index == 0 { path.move(to: point) } else { path.addLine(to: point) }
            }
        }
    }

    private func position(of entry: WeightEntry, in size: CGSize) -> CGPoint {
        let points = chronological
        guard let start = points.first?.date, let end = points.last?.date else { return .zero }
        let span = end.timeIntervalSince(start)
        let x = span > 0 ? entry.date.timeIntervalSince(start) / span : 0.5

        // At least half a kilogram of range either side, so two near-identical
        // readings do not draw as a cliff.
        let padding = max((maxKilograms - minKilograms) * 0.15, 0.5)
        let low = minKilograms - padding
        let high = maxKilograms + padding
        let y = (entry.weightKilograms - low) / (high - low)

        let inset: CGFloat = 4
        return CGPoint(
            x: inset + CGFloat(x) * (size.width - inset * 2),
            y: inset + CGFloat(1 - y) * (size.height - inset * 2)
        )
    }
}
