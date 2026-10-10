//
//  VerticalJumpHomeScreen.swift
//  PerformanceKit
//
//  Created by Findlay Wood on 10/10/2026.
//
import SwiftUI

/// Vertical Jump: the best as the screen's one big number with the latest
/// beneath it, then My Jumps and How It Works, with Start Test pinned to the
/// bottom. It is absent when this is someone else's centre.
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
                    PerformanceRow(icon: "list.bullet", title: "My Jumps", subtitle: "Every test you have done", showsDivider: true) {
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
                PerformancePrimaryButton(title: "Start Test", isEnabled: !viewModel.isLoading) {
                    viewModel.startTest()
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
        if let best = viewModel.best, let height = best.best?.height {
            VStack(spacing: 4) {
                Text("\(height, specifier: "%.1f")")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundStyle(Color.darkColor)
                + Text(" cm")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(Color.secondary)
                Text(best.date, format: .dateTime.day().month(.wide).year())
                    .font(.system(size: 13))
                    .foregroundStyle(Color.secondary)
                if let latest = viewModel.latest, latest.id != best.id, let latestHeight = latest.best?.height {
                    Text("Latest \(latestHeight, specifier: "%.1f") cm, \(latest.date.formatted(.dateTime.day().month(.abbreviated)))")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(Color.secondary)
                        .padding(.top, 6)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .performanceCard()
        } else {
            PerformanceEmptyCard(message: "No jumps recorded yet.", isLoading: viewModel.isLoading)
        }
    }
}
