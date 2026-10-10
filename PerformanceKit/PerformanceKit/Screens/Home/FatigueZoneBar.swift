//
//  FatigueZoneBar.swift
//  PerformanceKit
//
//  Created by Findlay Wood on 10/10/2026.
//
import SwiftUI

/// The three zones as one bar from 80% to 105%, with a marker where this
/// check's percentage sits. The ends are clamped, so a very low result or a
/// new best still draws a marker at the edge rather than off the bar. The
/// boundaries come from `FatigueZone`, never written here.
struct FatigueZoneBar: View {

    let fraction: Double

    private let lower = 0.80
    private let upper = 1.05

    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            ZStack(alignment: .leading) {
                HStack(spacing: 2) {
                    segment(.fatigued, from: lower, to: FatigueZone.cautionFrom, width: width)
                    segment(.caution, from: FatigueZone.cautionFrom, to: FatigueZone.freshFrom, width: width)
                    segment(.fresh, from: FatigueZone.freshFrom, to: upper, width: width)
                }
                Circle()
                    .fill(Color(.systemBackground))
                    .overlay(Circle().strokeBorder(Color.primary, lineWidth: 2.5))
                    .frame(width: 14, height: 14)
                    .offset(x: position(width: width) - 7)
            }
        }
        .frame(height: 14)
        .accessibilityHidden(true)
    }

    private func segment(_ zone: FatigueZone, from start: Double, to end: Double, width: CGFloat) -> some View {
        Capsule()
            .fill(zone.color)
            .frame(width: max(0, CGFloat((end - start) / (upper - lower)) * width - 2), height: 6)
    }

    private func position(width: CGFloat) -> CGFloat {
        let clamped = min(max(fraction, lower), upper)
        return CGFloat((clamped - lower) / (upper - lower)) * width
    }
}
