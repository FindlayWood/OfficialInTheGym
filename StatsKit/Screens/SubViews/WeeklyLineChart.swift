//
//  WeeklyLineChart.swift
//  StatsKit
//
//  Created by Findlay Wood on 27/03/2026.
//

import SwiftUI

struct WeeklyLineChart: View {
    let weeklyStats: [WeeklyStat]
    
    // MARK: Fill missing weeks for 90 days
    private var filledStats: [WeeklyStat] {
        let calendar = Calendar.current
        let now = calendar.startOfDay(for: Date())
        guard let startDate = calendar.date(byAdding: .day, value: -90, to: now) else { return [] }

        // Build a dictionary for fast lookup
        let dict = Dictionary(uniqueKeysWithValues: weeklyStats.map { (calendar.startOfDay(for: $0.week), $0) })

        var stats: [WeeklyStat] = []
        var currentDate = startDate

        while currentDate <= now {
            if let existing = dict[currentDate] {
                stats.append(existing)
            } else {
                stats.append(WeeklyStat(week: currentDate, volume: 0))
            }
            currentDate = calendar.date(byAdding: .weekOfYear, value: 1, to: currentDate)!
        }
        return stats
    }
    
    var body: some View {
        GeometryReader { geometry in
            let points = normalizedPoints(in: geometry.size)
            
            ZStack {
                // Smooth line
                Path { path in
                    guard points.count > 1 else {
                        if let first = points.first {
                            path.move(to: first)
                            path.addLine(to: first)
                        }
                        return
                    }

                    path.move(to: points[0])
                    for i in 1..<points.count {
                        let prev = points[i - 1]
                        let current = points[i]
                        let mid = CGPoint(x: (prev.x + current.x)/2, y: (prev.y + current.y)/2)
                        path.addQuadCurve(to: mid, control: CGPoint(x: prev.x, y: prev.y))
                        path.addQuadCurve(to: current, control: CGPoint(x: current.x, y: current.y))
                    }
                }
                .stroke(Color.blue, lineWidth: 2)
                
                // Dots
                ForEach(points.indices, id: \.self) { i in
                    Circle()
                        .frame(width: 6, height: 6)
                        .foregroundColor(.blue)
                        .position(points[i])
                }
                
                // X-axis labels
                VStack {
                    Spacer()
                    HStack {
                        Text(dateString(filledStats.first?.week))
                        Spacer()
                        Text(dateString(filledStats.last?.week))
                    }
                    .font(.caption)
                    .padding(.horizontal, 4)
                }
            }
        }
        .frame(height: 200)
        .padding()
    }
    
    // MARK: Normalize points to fit view
    private func normalizedPoints(in size: CGSize) -> [CGPoint] {
        guard !filledStats.isEmpty else { return [] }

        let volumes = filledStats.map { $0.volume }
        let minY = volumes.min() ?? 0
        let maxY = volumes.max() ?? 1

        // Avoid division by zero
        let deltaY = max(maxY - minY, 1)

        return filledStats.enumerated().map { index, stat in
            let x = size.width * CGFloat(index) / CGFloat(filledStats.count - 1)
            let yRatio = (stat.volume - minY) / deltaY
            let y = size.height * (1 - CGFloat(yRatio))
            return CGPoint(x: x, y: y)
        }
    }
    
    private func dateString(_ date: Date?) -> String {
        guard let date = date else { return "" }
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: date)
    }
}

#Preview {
    WeeklyLineChart(weeklyStats: [])
}
