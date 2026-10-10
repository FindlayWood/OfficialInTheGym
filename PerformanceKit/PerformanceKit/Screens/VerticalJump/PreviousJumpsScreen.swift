//
//  PreviousJumpsScreen.swift
//  PerformanceKit
//
//  Created by Findlay Wood on 10/10/2026.
//
import SwiftUI

/// Every saved jump, newest or highest first, in cm or inches. The two
/// switches are pills over the list rather than the legacy circle icons and
/// system segmented control.
struct PreviousJumpsScreen: View {

    @ObservedObject var viewModel: PreviousJumpsViewModel

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

                PerformanceSectionHeader(title: "Jumps")
                if viewModel.jumps.isEmpty {
                    PerformanceEmptyCard(message: "No jumps saved yet.", isLoading: viewModel.isLoading)
                } else {
                    let jumps = viewModel.sortedJumps
                    VStack(spacing: 0) {
                        ForEach(Array(jumps.enumerated()), id: \.element.time) { index, jump in
                            VerticalJumpRow(jump: jump, measurement: viewModel.measurement, showsDivider: index < jumps.count - 1)
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
        .navigationTitle("My Jumps")
        .navigationBarTitleDisplayMode(.inline)
    }
}
