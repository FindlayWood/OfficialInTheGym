//
//  JournalEntryDetailScreen.swift
//  PerformanceKit
//
//  Created by Findlay Wood on 10/10/2026.
//
import SwiftUI

/// One entry, read in full, in a sheet. It was a full-screen cover titled
/// "dd/MM"; a sheet says it is a glance that swipes away, and the date is
/// written out.
struct JournalEntryDetailScreen: View {

    @Environment(\.dismiss) private var dismiss
    let entry: JournalEntry

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 8) {
                    PerformanceSectionHeader(title: entry.date.formatted(.dateTime.weekday(.wide).day().month(.wide).year()))
                    Text(entry.entry)
                        .font(.system(size: 16))
                        .foregroundStyle(Color.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(16)
                        .performanceCard()
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
            }
            .background(Color(.systemBackground).ignoresSafeArea())
            .navigationTitle("Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .fontWeight(.semibold)
                        .tint(Color.darkColor)
                }
            }
        }
    }
}
