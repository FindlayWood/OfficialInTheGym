//
//  TrackedSessionDetailScreen.swift
//  PerformanceKit
//
//  Created by Findlay Wood on 10/10/2026.
//
import SwiftUI

/// One recorded session: the overall rating, the four ratings, the snapshot
/// of workload data taken when it was recorded, and the notes, each a card
/// under its own caption.
///
/// The snapshot section is drawn only when the session has one. The legacy
/// screen always drew its heading, over an empty grid for a session with none.
struct TrackedSessionDetailScreen: View {

    let session: TrackedSession
    let title: String

    private let columns = [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)]

    var body: some View {
        ScrollView {
            VStack(spacing: 8) {
                PerformanceSectionHeader(title: session.date.formatted(.dateTime.weekday(.wide).day().month(.wide).year()))
                VStack(spacing: 4) {
                    Text("\(session.ratings.overall)")
                        .font(.system(size: 56, weight: .bold))
                        .foregroundStyle(Color.darkColor)
                    Text("Overall rating")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(Color.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .performanceCard()
                .padding(.bottom, 16)

                PerformanceSectionHeader(title: "Ratings")
                LazyVGrid(columns: columns, spacing: 10) {
                    PerformanceStatCell(value: "\(session.ratings.technical)", label: "Technical")
                    PerformanceStatCell(value: "\(session.ratings.tactical)", label: "Tactical")
                    PerformanceStatCell(value: "\(session.ratings.physical)", label: "Physical")
                    PerformanceStatCell(value: "\(session.ratings.mental)", label: "Mental")
                }
                .padding(12)
                .performanceCard()
                .padding(.bottom, 16)

                if hasSnapshot {
                    PerformanceSectionHeader(title: "Going into it")
                    LazyVGrid(columns: columns, spacing: 10) {
                        if let ratio = session.workloadRatio {
                            PerformanceStatCell(value: format(ratio.acwr, places: 1), label: "ACWR")
                            PerformanceStatCell(value: format(ratio.acuteLoad, places: 0), label: "Acute load")
                            PerformanceStatCell(value: format(ratio.freshnessIndex, places: 1), label: "Freshness")
                            PerformanceStatCell(value: format(ratio.monotony, places: 2), label: "Monotony")
                            PerformanceStatCell(value: format(ratio.trainingStrain, places: 0), label: "Training strain")
                        }
                        if let workload = session.mostRecentWorkload {
                            PerformanceStatCell(value: workload.endTime.formatted(.dateTime.day().month(.abbreviated)), label: "Last workload")
                        }
                        if let wellness = session.wellness {
                            PerformanceStatCell(value: wellness.statusTitle, label: "Wellness")
                        }
                        if let cmj = session.cmj {
                            PerformanceStatCell(value: cmj.fatigueLevelTitle, label: "CMJ fatigue")
                        }
                    }
                    .padding(12)
                    .performanceCard()
                    .padding(.bottom, 16)
                }

                if !session.notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    PerformanceSectionHeader(title: "Notes")
                    Text(session.notes)
                        .font(.system(size: 15))
                        .foregroundStyle(Color.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(16)
                        .performanceCard()
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
        }
        .background(Color(.systemBackground).ignoresSafeArea())
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var hasSnapshot: Bool {
        session.workloadRatio != nil || session.mostRecentWorkload != nil || session.wellness != nil || session.cmj != nil
    }

    private func format(_ value: Double, places: Int) -> String {
        value.formatted(.number.precision(.fractionLength(places)))
    }
}
