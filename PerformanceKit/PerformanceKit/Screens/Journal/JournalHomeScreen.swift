//
//  JournalHomeScreen.swift
//  PerformanceKit
//
//  Created by Findlay Wood on 10/10/2026.
//
import SwiftUI

/// The journal: today's entries, then every entry, each a card, with
/// "New Entry" pinned to the bottom as the screen's one forward action.
///
/// The legacy screen was a default `List` (inset grouped, which the
/// conventions rule out) with the add action as a blue text row at the top.
struct JournalHomeScreen: View {

    @ObservedObject var viewModel: JournalHomeViewModel
    let makeEntryViewModel: () -> JournalEntryViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 8) {
                if !viewModel.todayEntries.isEmpty {
                    PerformanceSectionHeader(title: "Today")
                    entries(viewModel.todayEntries)
                        .padding(.bottom, 16)
                }

                PerformanceSectionHeader(title: "All Entries")
                if viewModel.entries.isEmpty {
                    PerformanceEmptyCard(
                        message: "Nothing written yet. Your journal is private to you.",
                        isLoading: viewModel.isLoading
                    )
                } else {
                    entries(viewModel.entries)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
        }
        .background(Color(.systemBackground).ignoresSafeArea())
        .performanceBottomBar {
            PerformancePrimaryButton(title: "New Entry") {
                viewModel.addNewEntry()
            }
        }
        .fullScreenCover(isPresented: $viewModel.isShowingNewEntry) {
            JournalEntryScreen(viewModel: makeEntryViewModel()) { entry in
                viewModel.entryAdded(entry)
            }
        }
        .sheet(item: $viewModel.selectedEntry) { entry in
            JournalEntryDetailScreen(entry: entry)
        }
        .task {
            await viewModel.load()
        }
        .navigationTitle("Journal")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func entries(_ entries: [JournalEntry]) -> some View {
        VStack(spacing: 10) {
            ForEach(entries) { entry in
                Button {
                    viewModel.selectedEntry = entry
                } label: {
                    JournalEntryRow(entry: entry)
                }
                .buttonStyle(.plain)
            }
        }
    }
}
