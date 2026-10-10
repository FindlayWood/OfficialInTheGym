//
//  JumpTestHistoryScreen.swift
//  PerformanceKit
//
//  Created by Findlay Wood on 10/10/2026.
//
import SwiftUI

/// Every saved session of one test, newest or highest first, in cm or inches. The two
/// switches are pills over the list rather than the legacy circle icons and
/// system segmented control.
struct JumpTestHistoryScreen: View {

    @ObservedObject var viewModel: JumpTestHistoryViewModel

    private var sortBinding: Binding<Bool> {
        Binding(get: { viewModel.sortedByDate }, set: { viewModel.sortByDate($0) })
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 8) {
                HStack {
                    PerformancePillPicker(options: [true, false], selection: sortBinding) { $0 ? "Newest" : "Highest" }
                    Spacer()
                    PerformancePillPicker(options: JumpMeasurement.allCases, selection: $viewModel.measurement) { $0.title }
                }
                .padding(.bottom, 12)

                PerformanceSectionHeader(title: "Tests")
                if viewModel.sessions.isEmpty {
                    PerformanceEmptyCard(message: "No tests saved yet.", isLoading: viewModel.isLoading)
                } else {
                    let sessions = viewModel.sortedSessions
                    VStack(spacing: 0) {
                        ForEach(Array(sessions.enumerated()), id: \.element.id) { index, session in
                            JumpSessionRow(session: session, measurement: viewModel.measurement, showsDivider: index < sessions.count - 1)
                        }
                    }
                    .performanceCard()
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
        }
        .background(Color(.systemBackground).ignoresSafeArea())
        .task {
            await viewModel.load()
        }
        .navigationTitle("\(viewModel.kind.title) History")
        .navigationBarTitleDisplayMode(.inline)
    }
}
