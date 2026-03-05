//
//  RecordingProgressRing.swift
//  MyDayKit
//
//  Created by Findlay Wood on 20/01/2026.
//

import SwiftUI

struct RecordingProgressRing: View {
    
    let recordingProgress: Double
    let recordingDuration: Double

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.white.opacity(0.2), lineWidth: 6)

            Circle()
                .trim(from: 0, to: recordingProgress)
                .stroke(
                    Color.red,
                    style: StrokeStyle(lineWidth: 6, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.linear, value: recordingProgress)

            Text("\(Int(16 - recordingDuration))")
                .font(.caption)
                .foregroundColor(.white)
        }
        .frame(width: 56, height: 56)
    }
}

#Preview {
    RecordingProgressRing(
        recordingProgress: 1,
        recordingDuration: 10
    )
}
