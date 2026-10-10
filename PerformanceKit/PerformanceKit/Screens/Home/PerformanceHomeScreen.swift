//
//  PerformanceHomeScreen.swift
//  PerformanceKit
//
//  Created by Findlay Wood on 10/10/2026.
//
import SwiftUI

/// The PERFORMANCE tab's home, a readiness dashboard: this week's fatigue check
/// as the lead card, with its own start button, the key numbers beneath, then
/// the tests. It answers "am I fresh?" before it lists anything; the tab used
/// to be a menu, and a menu always reads as a settings page. **Nothing is
/// pinned to the bottom of the tab's root**, which would sit over the tab bar.
struct PerformanceHomeScreen: View {

    @ObservedObject var viewModel: PerformanceDashboardViewModel

    private let columns = [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)]

    var body: some View {
        ScrollView {
            VStack(spacing: 8) {
                PerformanceSectionHeader(title: "This Week")
                if viewModel.hasLoaded {
                    FatigueCheckCard(
                        check: viewModel.check,
                        isDue: viewModel.isCheckDue,
                        onStart: viewModel.canRecord ? { viewModel.startCheck() } : nil
                    )
                        .padding(.bottom, 16)
                } else {
                    PerformanceEmptyCard(message: "", isLoading: true)
                        .padding(.bottom, 16)
                }

                PerformanceSectionHeader(title: "Key Numbers")
                LazyVGrid(columns: columns, spacing: 10) {
                    PerformanceStatCell(value: height(viewModel.bestCMJ), label: "CMJ cm")
                    PerformanceStatCell(value: height(viewModel.bestVerticalJump), label: "Vertical cm")
                    PerformanceStatCell(
                        value: viewModel.bestDropJump?.best?.reactiveStrengthIndex.map { $0.formatted(.number.precision(.fractionLength(2))) } ?? "—",
                        label: "Drop jump RSI"
                    )
                    PerformanceStatCell(
                        value: viewModel.bestPower.map { $0.wattsPerKilogram.formatted(.number.precision(.fractionLength(1))) } ?? "—",
                        label: "Power W/kg"
                    )
                }
                .padding(12)
                .performanceCard()
                .padding(.bottom, 16)

                PerformanceSectionHeader(title: "Tests")
                VStack(spacing: 0) {
                    ForEach(Array(viewModel.tools.enumerated()), id: \.element) { index, tool in
                        PerformanceRow(
                            icon: tool.systemImage,
                            title: tool.title,
                            subtitle: tool.message,
                            showsDivider: index < viewModel.tools.count - 1
                        ) {
                            viewModel.select(tool)
                        }
                    }
                }
                .performanceCard()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
        }
        .background(Color(.systemBackground).ignoresSafeArea())
        .task {
            if !viewModel.hasLoaded { await viewModel.load() }
        }
    }

    private func height(_ session: JumpTestSession?) -> String {
        session?.best.map { $0.height.formatted(.number.precision(.fractionLength(1))) } ?? "—"
    }
}
