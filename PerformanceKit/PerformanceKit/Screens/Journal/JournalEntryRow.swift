//
//  JournalEntryRow.swift
//  PerformanceKit
//
//  Created by Findlay Wood on 10/10/2026.
//
import SwiftUI

/// One entry in the journal list: its date, then up to three lines of it. The
/// legacy screen wrote this out twice, once per section.
struct JournalEntryRow: View {

    let entry: JournalEntry

    var body: some View {
        VStack(alignment: .leading) {
            Text(entry.date, format: .dateTime.day().month().year())
                .foregroundColor(.secondary)
                .font(.footnote.bold())
            Text(entry.entry)
                .foregroundColor(.primary)
                .font(.body.weight(.medium))
                .multilineTextAlignment(.leading)
                .lineLimit(3)
        }
    }
}
