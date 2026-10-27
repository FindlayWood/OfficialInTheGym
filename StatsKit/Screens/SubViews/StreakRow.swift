//
//  StreakRow.swift
//  StatsKit
//
//  Created by Findlay Wood on 27/10/2026.
//

import SwiftUI

/// The streak line, on the pro home's activity card and on its own card in the free view. One
/// view so the two never word a streak differently.
struct StreakRow: View {
    let streak: Int

    var body: some View {
        HStack(spacing: 12) {
            Text(streak > 0 ? "🔥" : "💤")
                .font(.title2)
            VStack(alignment: .leading, spacing: 2) {
                Text(streak > 0 ? "\(streak) day streak" : "No active streak")
                    .font(.headline)
                Text(streak > 0 ? "Keep it going!" : "Log a workout to start one")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(16)
    }
}

#Preview {
    StreakRow(streak: 4)
        .background(Color(.secondarySystemGroupedBackground))
}
