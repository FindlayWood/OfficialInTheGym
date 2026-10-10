//
//  JournalHomeScreen.swift
//  PerformanceKit
//
//  Created by Findlay Wood on 10/10/2026.
//
import SwiftUI

/// The legacy `JournalHomeView`, moved as it was: an add button, today's
/// entries, then every entry. Tapping one opens it full screen.
struct JournalHomeScreen: View {

    @ObservedObject var viewModel: JournalHomeViewModel
    let makeEntryViewModel: () -> JournalEntryViewModel

    var body: some View {
        List {
            Section {
                Button {
                    viewModel.addNewEntry()
                } label: {
                    Text("Add new journal entry")
                }
            }

            if !viewModel.todayEntries.isEmpty {
                Section {
                    ForEach(viewModel.todayEntries) { entry in
                        JournalEntryRow(entry: entry)
                            .onTapGesture { viewModel.selectedEntry = entry }
                    }
                } header: {
                    Text("Today's Entries")
                }
            }

            Section {
                ForEach(viewModel.entries) { entry in
                    JournalEntryRow(entry: entry)
                        .onTapGesture { viewModel.selectedEntry = entry }
                }
            } header: {
                Text("All Entries")
            }
        }
        .fullScreenCover(isPresented: $viewModel.isShowingNewEntry) {
            JournalEntryScreen(viewModel: makeEntryViewModel()) { entry in
                viewModel.entryAdded(entry)
            }
        }
        .fullScreenCover(item: $viewModel.selectedEntry) { entry in
            JournalEntryDetailScreen(entry: entry)
        }
        .task {
            await viewModel.load()
        }
        .navigationTitle("Journal")
        .navigationBarTitleDisplayMode(.inline)
    }
}
