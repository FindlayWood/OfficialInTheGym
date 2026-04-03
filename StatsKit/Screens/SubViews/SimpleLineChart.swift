//
//  SimpleLineChart.swift
//  StatsKit
//
//  Created by Findlay Wood on 27/03/2026.
//

import SwiftUI

struct SimpleLineChart: View {
    let data: [ExerciseDailyStats]

    var body: some View {
        GeometryReader { geometry in
            let points = normalizedPoints(in: geometry.size)

            Path { path in
                guard let first = points.first else { return }
                path.move(to: first)

                for point in points.dropFirst() {
                    path.addLine(to: point)
                }
            }
            .stroke(Color.blue, lineWidth: 2)
        }
        .frame(height: 200)
    }

    private func normalizedPoints(in size: CGSize) -> [CGPoint] {
        guard !data.isEmpty else { return [] }

        let volumes = data.map { $0.totalVolume }

        guard let minY = volumes.min(),
              let maxY = volumes.max(),
              maxY > minY else {
            return []
        }

        return data.enumerated().map { index, item in
            let x = size.width * CGFloat(index) / CGFloat(data.count - 1)

            let yRatio = (item.totalVolume - minY) / (maxY - minY)
            let y = size.height * (1 - CGFloat(yRatio)) // flip for UI coords

            return CGPoint(x: x, y: y)
        }
    }
}

#Preview {
    SimpleLineChart(data: [])
}
