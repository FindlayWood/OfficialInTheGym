//
//  BalanceHomeScreen.swift
//  PerformanceKit
//
//  Created by Findlay Wood on 10/10/2026.
//
import SwiftUI

/// Balance: the latest result as each leg's sway side by side with the gap
/// between them, then History and How It Works, with Start Test pinned to the
/// bottom.
struct BalanceHomeScreen: View {

    @ObservedObject var viewModel: BalanceHomeViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 8) {
                PerformanceSectionHeader(title: "Latest")
                latestCard
                    .padding(.bottom, 16)

                PerformanceSectionHeader(title: "Tests")
                VStack(spacing: 0) {
                    PerformanceRow(icon: "list.bullet", title: "History", subtitle: "Every test you have done", showsDivider: true) {
                        viewModel.history()
                    }
                    PerformanceRow(icon: "questionmark", title: "How It Works", subtitle: "Standing still on one leg") {
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
        .task { await viewModel.load() }
        .navigationTitle("Balance")
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    private var latestCard: some View {
        if let latest = viewModel.latest {
            VStack(spacing: 8) {
                Text(latest.condition.title.uppercased())
                    .font(.system(size: 12, weight: .semibold))
                    .tracking(0.8)
                    .foregroundStyle(Color.secondary)
                HStack(spacing: 0) {
                    legColumn(.left, attempt: latest.best(on: .left))
                    Divider().frame(height: 48)
                    legColumn(.right, attempt: latest.best(on: .right))
                }
                if let symmetry = latest.symmetry {
                    Text(symmetry.summary)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(symmetry.isNotable ? Color.matteAmber : Color.secondary)
                }
                Text(latest.date, format: .dateTime.day().month(.wide).year())
                    .font(.system(size: 13))
                    .foregroundStyle(Color.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .performanceCard()
        } else {
            PerformanceEmptyCard(message: "No tests recorded yet.", isLoading: viewModel.isLoading)
        }
    }

    private func legColumn(_ side: JumpSide, attempt: BalanceAttempt?) -> some View {
        VStack(spacing: 2) {
            Text(side.title)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Color.secondary)
            if let attempt {
                Text(attempt.sway.formatted(.number.precision(.fractionLength(1))))
                    .font(.system(size: 36, weight: .bold))
                    .foregroundStyle(Color.darkColor)
                + Text(" mg")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color.secondary)
            } else {
                Text("No full stand")
                    .font(.system(size: 14))
                    .foregroundStyle(Color.secondary)
                    .frame(height: 43)
            }
        }
        .frame(maxWidth: .infinity)
    }
}
