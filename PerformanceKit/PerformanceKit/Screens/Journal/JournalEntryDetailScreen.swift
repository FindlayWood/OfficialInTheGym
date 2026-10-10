//
//  JournalEntryDetailScreen.swift
//  PerformanceKit
//
//  Created by Findlay Wood on 10/10/2026.
//
import SwiftUI

/// One entry, read in full. The legacy `ViewJournalEntryView`, moved as it
/// was, titled with the entry's day and month.
struct JournalEntryDetailScreen: View {

    @Environment(\.dismiss) private var dismiss
    let entry: JournalEntry

    var body: some View {
        NavigationStack {
            ScrollView {
                Text(entry.entry)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding()
            }
            .navigationTitle(Self.titleFormatter.string(from: entry.date))
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Dismiss")
                            .foregroundColor(Color.darkColor)
                            .fontWeight(.bold)
                    }
                }
            }
        }
    }

    /// The app target's `getDayMonthFormat()`: "dd/MM".
    private static let titleFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM"
        return formatter
    }()
}
