//
//  TrackerHomeScreen.swift
//  PerformanceKit
//
//  Created by Findlay Wood on 10/10/2026.
//
import SwiftUI

/// Match Tracker or Practice Tracker: a line on what it is for, every recorded
/// session newest first as a card each, and Record pinned to the bottom.
///
/// The legacy screens were a default `List` led by a 100pt icon and a
/// large-title heading repeating the navigation title, with white session cards
/// that were unreadable in dark mode.
struct TrackerHomeScreen: View {

    @ObservedObject var viewModel: TrackerHomeViewModel
    let makeNewEntryViewModel: () -> NewTrackedSessionViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 8) {
                Text(viewModel.kind.welcome)
                    .font(.system(size: 15))
                    .foregroundStyle(Color.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 4)
                    .padding(.bottom, 16)

                PerformanceSectionHeader(title: viewModel.kind.previousHeader)
                if viewModel.sessions.isEmpty {
                    PerformanceEmptyCard(message: viewModel.kind.emptyMessage, isLoading: viewModel.isLoading)
                } else {
                    VStack(spacing: 10) {
                        ForEach(viewModel.sessions, id: \.id) { session in
                            Button {
                                viewModel.select(session)
                            } label: {
                                TrackedSessionRow(session: session)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
        }
        .background(Color(.systemBackground).ignoresSafeArea())
        .performanceBottomBar {
            if viewModel.canRecord {
                PerformancePrimaryButton(title: viewModel.kind.recordButtonTitle) {
                    viewModel.recordNew()
                }
            }
        }
        .sheet(isPresented: $viewModel.isShowingNewEntry) {
            NewTrackedSessionScreen(viewModel: makeNewEntryViewModel()) { session in
                viewModel.sessionRecorded(session)
            }
        }
        .task {
            await viewModel.load()
        }
        .navigationTitle(viewModel.kind.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}
