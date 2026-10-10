//
//  TrackerHomeScreen.swift
//  PerformanceKit
//
//  Created by Findlay Wood on 10/10/2026.
//
import SwiftUI

/// The legacy `MatchTrackerView` and `PracticeTrackerHomeView`, one screen now:
/// the tracker's icon and welcome, a button to record a new session, then every
/// session recorded, newest first.
struct TrackerHomeScreen: View {

    @ObservedObject var viewModel: TrackerHomeViewModel
    let makeNewEntryViewModel: () -> NewTrackedSessionViewModel

    var body: some View {
        List {
            Section {
                HStack {
                    Spacer()
                    VStack {
                        Image(viewModel.kind.iconName, bundle: .performanceKit)
                            .resizable()
                            .frame(width: 100, height: 100)
                        Text(viewModel.kind.title)
                            .font(.largeTitle.bold())
                            .foregroundColor(Color.darkColor)
                        Text(viewModel.kind.welcome)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    Spacer()
                }
            }
            .listRowBackground(Color.clear)

            if viewModel.canRecord {
                Section {
                    Button {
                        viewModel.recordNew()
                    } label: {
                        HStack {
                            Image(viewModel.kind.buttonIconName, bundle: .performanceKit)
                                .resizable()
                                .frame(width: 30, height: 30)
                            Text(viewModel.kind.recordButtonTitle)
                                .font(.headline)
                        }
                        .padding(.vertical, 12)
                    }
                } header: {
                    Text(viewModel.kind.newSectionHeader)
                }
            }

            Section {
                if viewModel.isLoading && viewModel.sessions.isEmpty {
                    ProgressView()
                } else if viewModel.sessions.isEmpty {
                    Text(viewModel.kind.emptyMessage)
                        .font(.footnote)
                        .foregroundColor(.secondary)
                } else {
                    ForEach(viewModel.sessions, id: \.id) { session in
                        TrackedSessionRow(session: session)
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                            .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
                            .onTapGesture { viewModel.select(session) }
                    }
                }
            } header: {
                Text(viewModel.kind.previousHeader)
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
    }
}
