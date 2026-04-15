//
//  MiniBarChart.swift
//  StatsKit
//
//  Created by Findlay Wood on 15/04/2026.
//

import SwiftUI

// MARK: - MiniBarChart
struct MiniBarChart: View {
    let title: String
    let values: [Double]
    let labels: [String]
    let color: Color
    let formatValue: (Double) -> String

    private var maxValue: Double {
        values.max() ?? 1
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.caption).fontWeight(.semibold)
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
                .tracking(0.5)

            GeometryReader { geo in
                let barCount = values.count
                let spacing: CGFloat = 3
                let totalSpacing = spacing * CGFloat(barCount - 1)
                let barWidth = (geo.size.width - totalSpacing) / CGFloat(barCount)
                let chartHeight = geo.size.height - 16 // leave room for labels

                HStack(alignment: .bottom, spacing: spacing) {
                    ForEach(Array(values.enumerated()), id: \.offset) { index, value in
                        VStack(spacing: 0) {
                            Spacer(minLength: 0)

                            RoundedRectangle(cornerRadius: 3)
                                .fill(value > 0 ? color.opacity(0.85) : Color(.tertiarySystemFill))
                                .frame(
                                    width: barWidth,
                                    height: maxValue > 0
                                        ? max(4, CGFloat(value / maxValue) * chartHeight)
                                        : 4
                                )
                        }
                        .frame(width: barWidth, height: chartHeight)
                    }
                }
                .frame(height: chartHeight)

                // X axis labels — only show first, middle, last
                HStack(alignment: .bottom) {
                    if let first = labels.first {
                        Text(first)
                            .font(.system(size: 9))
                            .foregroundStyle(.secondary)
                            .frame(width: barWidth, alignment: .leading)
                    }

                    Spacer()

                    if labels.count > 2, let mid = labels[safe: labels.count / 2] {
                        Text(mid)
                            .font(.system(size: 9))
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    if let last = labels.last {
                        Text(last)
                            .font(.system(size: 9))
                            .foregroundStyle(.secondary)
                            .frame(width: barWidth, alignment: .trailing)
                    }
                }
                .frame(maxHeight: .infinity, alignment: .bottom)
            }
            .frame(height: 120)
        }
        .padding(16)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(.separator).opacity(0.4), lineWidth: 0.5)
        )
        .padding(.horizontal, 16)
    }
}

// MARK: - Safe subscript
private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
