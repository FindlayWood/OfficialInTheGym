//
//  JournalEntryRow.swift
//  PerformanceKit
//
//  Created by Findlay Wood on 10/10/2026.
//
import SwiftUI

/// One entry in the journal: its date as a caption, then up to three lines of
/// it, as a card of its own.
struct JournalEntryRow: View {

    let entry: JournalEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(entry.date, format: .dateTime.weekday(.wide).day().month(.wide))
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Color.secondary)
            Text(entry.entry)
                .font(.system(size: 15))
                .foregroundStyle(Color.primary)
                .multilineTextAlignment(.leading)
                .lineLimit(3)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .performanceCard()
    }
}
