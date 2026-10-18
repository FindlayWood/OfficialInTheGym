//
//  PerformanceSamplePreviewNavBar.swift
//  PerformanceKit
//
//  Created by Findlay Wood on 18/10/2026.
//

import SwiftUI

/// The sample preview's bar: back chevron, centred title, divider, on `systemBackground`. **A copy
/// of MyDayKit's `MyDayWorkoutNavBar` — keep the two in step.** The previews sit beside the example
/// workout on the welcome screen, and the workout draws that bar (its system bar has to go, for the
/// set detail overlay); a system bar here made moving between them look like two different apps.
struct PerformanceSamplePreviewNavBar: View {

    let title: String
    var onBack: (() -> Void)?

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                Text(title)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(Color.primary)
                    .lineLimit(1)
                    .padding(.horizontal, 56)

                HStack(spacing: 0) {
                    Button {
                        onBack?()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(Color.darkColor)
                            .frame(width: 44, height: 44)
                            .contentShape(Rectangle())
                    }
                    .accessibilityLabel("Back")

                    Spacer()
                }
            }
            .frame(height: 44)
            .padding(.horizontal, 4)

            Divider()
        }
        .background(Color(UIColor.systemBackground).ignoresSafeArea(edges: .top))
    }
}

#Preview {
    VStack(spacing: 0) {
        PerformanceSamplePreviewNavBar(title: "Performance")
        Color.pageColor
    }
}
