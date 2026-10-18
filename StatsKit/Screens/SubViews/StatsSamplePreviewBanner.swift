//
//  StatsSamplePreviewBanner.swift
//  StatsKit
//
//  Created by Findlay Wood on 18/10/2026.
//

import SwiftUI

/// Says, before anything else on `StatsSamplePreviewScreen`, that the numbers are made up and that
/// the tab is pro. The promise in the second line is true: free users' logs are written as raw logs
/// and `DailyTotal`s, so subscribing shows their whole history. Keep in step with PerformanceKit's
/// `PerformanceSamplePreviewBanner` — both are reached from the same welcome screen.
struct StatsSamplePreviewBanner: View {

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

            Text("Twelve weeks of example training. Stats are part of INTHEGYM pro, and everything you log is counted from day one, so your history is here whenever you subscribe.")
                .font(.system(size: 14))
                .foregroundStyle(Color.primary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

#Preview {
    StatsSamplePreviewBanner()
        .padding()
        .background(Color.pageColor)
}
