//
//  TrackedSessionRow.swift
//  PerformanceKit
//
//  Created by Findlay Wood on 10/10/2026.
//
import SwiftUI

/// A recorded session in the list: its date, the overall rating large, then the
/// four ratings. The legacy `MatchTrackerListView` / `PracticeTrackerListView`,
/// which were identical. Its card is `systemBackground`, not the legacy `.white`,
/// which was unreadable in dark mode.
struct TrackedSessionRow: View {

    let session: TrackedSession

    var body: some View {
        VStack {
            HStack {
                Text(TrackedSessionDateFormat.string(from: session.date))
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
            }
            HStack {
                Spacer()
                Text(session.ratings.overall, format: .number)
                    .font(.largeTitle.bold())
                    .foregroundColor(Color.darkColor)
                    .padding()
                Spacer()
            }
            HStack {
                rating(session.ratings.technical, "Technical")
                rating(session.ratings.tactical, "Tactical")
                rating(session.ratings.physical, "Physical")
                rating(session.ratings.mental, "Mental")
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(8)
    }

    private func rating(_ value: Int, _ title: String) -> some View {
        VStack {
            Text(value, format: .number)
                .font(.headline)
                .foregroundColor(.primary)
            Text(title)
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }
}
