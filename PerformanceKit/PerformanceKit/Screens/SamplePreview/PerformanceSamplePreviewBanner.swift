//
//  PerformanceSamplePreviewBanner.swift
//  PerformanceKit
//
//  Created by Findlay Wood on 18/10/2026.
//
import SwiftUI

/// Says, above the sample dashboard, that the results are made up and that the tab is pro. Keep in
/// step with StatsKit's `StatsSamplePreviewBanner` — the two previews are reached from the same
/// welcome screen and should read as one thing.
struct PerformanceSamplePreviewBanner: View {

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Text("SAMPLE DATA")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(Color.secondary)
                    .tracking(1.2)
                Spacer()
                Text("PRO")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(Color.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Capsule().fill(Color.darkColor))
            }

            Text("Ten weeks of example jump tests. Measure jumps on your phone's camera and check every week whether you're fresh or fatigued — part of INTHEGYM pro.")
                .font(.system(size: 14))
                .foregroundStyle(Color.primary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .performanceCard()
    }
}

#Preview {
    PerformanceSamplePreviewBanner()
        .padding()
}
