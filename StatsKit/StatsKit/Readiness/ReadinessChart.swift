//
//  ReadinessChart.swift
//  StatsKit
//
//  Created by Findlay Wood on 10/11/2026.
//

import SwiftUI

/// A metric over days on a 0–1 scale: each check-in as a faint dot, the seven-day average as the
/// line, injuries shaded behind. Hand-built, as every chart is.
///
/// **One colour, `darkColor`, with opacity separating the two** — the dots are the raw answers,
/// the line is what to read. Colouring dots by how good a day was would put a judgement on a
/// single answer the average is there to smooth.
///
/// The line breaks wherever the average does (`ReadinessSeries.minimumForAverage`), rather than
/// sloping across a gap and implying days nobody answered.
struct ReadinessChart: View {

    let series: ReadinessSeries
    var injuryBands: [ClosedRange<Int>] = []
    var height: CGFloat = 120
    var showsLabels = true

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            GeometryReader { geo in
                let w = geo.size.width
                let h = geo.size.height
                ZStack(alignment: .topLeading) {
                    bands(width: w, height: h)
                    guides(width: w, height: h)
                    dots(width: w, height: h)
                    line(width: w, height: h)
                }
            }
            .frame(height: height)

            if showsLabels {
                HStack {
                    Text(label(at: 0))
                    Spacer()
                    Text(label(at: series.dayKeys.count / 2))
                    Spacer()
                    Text(series.dayKeys.last == StatsDay.key(for: .now) ? "Today" : label(at: series.dayKeys.count - 1))
                }
                .font(.system(size: 9))
                .foregroundStyle(.secondary)
            }
        }
    }

    private func x(_ index: Int, width: CGFloat) -> CGFloat {
        series.dayKeys.count > 1 ? width * CGFloat(index) / CGFloat(series.dayKeys.count - 1) : width / 2
    }

    private func y(_ value: Double, height: CGFloat) -> CGFloat {
        height * CGFloat(1 - min(max(value, 0), 1))
    }

    private func label(at index: Int) -> String {
        guard series.dayKeys.indices.contains(index) else { return "" }
        return InjuryDayFormat.short(series.dayKeys[index])
    }

    @ViewBuilder
    private func bands(width: CGFloat, height: CGFloat) -> some View {
        let slot = series.dayKeys.count > 1 ? width / CGFloat(series.dayKeys.count - 1) : width
        ForEach(Array(injuryBands.enumerated()), id: \.offset) { _, band in
            let start = max(0, x(band.lowerBound, width: width) - slot / 2)
            let end = min(width, x(band.upperBound, width: width) + slot / 2)
            Rectangle()
                .fill(Color.matteRed.opacity(0.18))
                .frame(width: max(2, end - start), height: height)
                .offset(x: start)
        }
    }

    @ViewBuilder
    private func guides(width: CGFloat, height: CGFloat) -> some View {
        ForEach([0.25, 0.5, 0.75], id: \.self) { level in
            Path { path in
                path.move(to: CGPoint(x: 0, y: y(level, height: height)))
                path.addLine(to: CGPoint(x: width, y: y(level, height: height)))
            }
            .stroke(Color.secondary.opacity(level == 0.5 ? 0.35 : 0.18), style: StrokeStyle(lineWidth: 0.5, dash: [4, 3]))
        }
    }

    @ViewBuilder
    private func dots(width: CGFloat, height: CGFloat) -> some View {
        ForEach(Array(series.values.enumerated()), id: \.offset) { index, value in
            if let value {
                Circle()
                    .fill(Color.darkColor.opacity(0.3))
                    .frame(width: 5, height: 5)
                    .position(x: x(index, width: width), y: y(value, height: height))
            }
        }
    }

    private func line(width: CGFloat, height: CGFloat) -> some View {
        Path { path in
            var drawing = false
            for (index, value) in series.average.enumerated() {
                guard let value else {
                    drawing = false
                    continue
                }
                let point = CGPoint(x: x(index, width: width), y: y(value, height: height))
                if drawing {
                    path.addLine(to: point)
                } else {
                    path.move(to: point)
                    drawing = true
                }
            }
        }
        .stroke(Color.darkColor, style: StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round))
    }
}
