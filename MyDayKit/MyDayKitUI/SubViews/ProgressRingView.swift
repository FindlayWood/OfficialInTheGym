//
//  ProgressRingView.swift
//  MyDayKit
//
//  Created by Findlay Wood on 02/11/2025.
//

import SwiftUI

struct ProgressRingView: View {
    let current: Int
    let goal: Int
    let lineWidth: CGFloat
    let ringColor: Color
    let backgroundColor: Color

    private var progress: Double {
        guard goal > 0 else { return 0 }
        return min(Double(current) / Double(goal), 1.0)
    }

    var body: some View {
        ZStack {
            // Background Circle
            Circle()
                .stroke(backgroundColor, lineWidth: lineWidth)

            // Progress Circle
            Circle()
                .trim(from: 0.0, to: progress)
                .stroke(
                    ringColor,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90)) // Start from top

            // Center Text
            Text("\(current)/\(goal)")
                .font(.system(size: 16, weight: .semibold))
        }
        .frame(width: 50, height: 50)
    }
}

#Preview {
    ProgressRingView(current: 1, goal: 10, lineWidth: 2, ringColor: .red, backgroundColor: .green)
}
