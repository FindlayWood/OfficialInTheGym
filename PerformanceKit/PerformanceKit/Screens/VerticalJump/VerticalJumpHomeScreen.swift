//
//  VerticalJumpHomeScreen.swift
//  PerformanceKit
//
//  Created by Findlay Wood on 10/10/2026.
//
import SwiftUI

/// Vertical Jump: the best jump as the screen's one big number, then My Jumps
/// and How It Works as rows, with Record New Jump pinned to the bottom.
///
/// The legacy screen was a default `List` with three blue text buttons in
/// sections of their own. Recording is the action people come here for, so it
/// is the primary button, and it is absent when this is someone else's centre.
struct VerticalJumpHomeScreen: View {

    @ObservedObject var viewModel: VerticalJumpHomeViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 8) {
                PerformanceSectionHeader(title: "Best Jump")
                bestJump
                    .padding(.bottom, 16)

                PerformanceSectionHeader(title: "Jumps")
                VStack(spacing: 0) {
                    PerformanceRow(icon: "list.bullet", title: "My Jumps", subtitle: "Every jump you have saved", showsDivider: true) {
                        viewModel.previousJumps()
                    }
                    PerformanceRow(icon: "questionmark", title: "How It Works", subtitle: "Recording and tagging a jump") {
                        viewModel.help()
                    }
                }
                .performanceCard()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
        }
        .background(Color(.systemBackground).ignoresSafeArea())
        .performanceBottomBar {
            if viewModel.canRecord {
                PerformancePrimaryButton(title: "Record New Jump", isEnabled: !viewModel.isLoading) {
                    viewModel.recordNewJump()
                }
            }
        }
        .task {
            await viewModel.load()
        }
        .navigationTitle("Vertical Jump")
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    private var bestJump: some View {
        if let max = viewModel.max {
            VStack(spacing: 4) {
                Text("\(max.height, specifier: "%.1f")")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundStyle(Color.darkColor)
                + Text(" cm")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(Color.secondary)
                Text(max.time, format: .dateTime.day().month(.wide).year())
                    .font(.system(size: 13))
                    .foregroundStyle(Color.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .performanceCard()
        } else {
            PerformanceEmptyCard(message: "No jumps recorded yet.", isLoading: viewModel.isLoading)
        }
    }
}
