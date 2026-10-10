//
//  TrackedSessionDetailScreen.swift
//  PerformanceKit
//
//  Created by Findlay Wood on 10/10/2026.
//
import SwiftUI

/// One recorded session: its ratings, the snapshot of workload data taken when
/// it was recorded, and the notes. The legacy `MatchTrackerDetailView` /
/// `PracticeTrackerDetailView`, which were identical. Cards are
/// `systemBackground` rather than the legacy `.white`, which was unreadable in
/// dark mode.
struct TrackedSessionDetailScreen: View {

    let session: TrackedSession
    let title: String

    private let columns: [GridItem] = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack {
                heading("Ratings")
                HStack {
                    Spacer()
                    Text(session.ratings.overall, format: .number)
                        .font(.largeTitle.bold())
                        .foregroundStyle(Color.darkColor)
                    Spacer()
                }
                Text("Overall Match Rating")
                    .font(.footnote)
                    .foregroundColor(Color.darkColor)
                Text(TrackedSessionDateFormat.string(from: session.date))
                    .font(.caption)
                    .foregroundColor(.secondary)
                LazyVGrid(columns: columns) {
                    card(Text(session.ratings.technical, format: .number), "Technical Rating")
                    card(Text(session.ratings.tactical, format: .number), "Tactical Rating")
                    card(Text(session.ratings.physical, format: .number), "Physical Rating")
                    card(Text(session.ratings.mental, format: .number), "Mental Rating")
                }
                .padding(.horizontal)

                HStack {
                    VStack(alignment: .leading) {
                        Text("Workload Data")
                            .font(.title.bold())
                            .foregroundColor(Color.darkColor)
                        Text("This is data at the time of entering match details")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                }
                .padding([.horizontal, .top])
                LazyVGrid(columns: columns) {
                    if let ratio = session.workloadRatio {
                        card(Text(ratio.acwr.rounded(toPlaces: 1), format: .number), "ACWR")
                        card(Text(ratio.acuteLoad, format: .number), "Acute Load")
                        card(Text(ratio.freshnessIndex.rounded(toPlaces: 1), format: .number), "Freshness Index")
                        card(Text(ratio.monotony.rounded(toPlaces: 2), format: .number), "Monotony")
                        card(Text(ratio.trainingStrain.rounded(toPlaces: 2), format: .number), "Training Strain")
                    }
                    if let wellness = session.wellness {
                        card(Text(wellness.statusTitle), "Wellness Status")
                    }
                    if let cmj = session.cmj {
                        card(Text(cmj.fatigueLevelTitle), "CMJ Fatigue Level")
                    }
                    if let workload = session.mostRecentWorkload {
                        card(Text(TrackedSessionDateFormat.string(from: workload.endTime)), "Most Recent Workload")
                    }
                }
                .padding(.horizontal)

                heading("Notes")
                Text(session.notes)
                    .font(.body)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal)
            }
        }
        .navigationTitle(title)
    }

    private func heading(_ text: String) -> some View {
        HStack {
            Text(text)
                .font(.title.bold())
                .foregroundColor(Color.darkColor)
            Spacer()
        }
        .padding([.horizontal, .top])
    }

    private func card(_ value: Text, _ title: String) -> some View {
        VStack {
            value
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.systemBackground))
        .cornerRadius(8)
    }
}
