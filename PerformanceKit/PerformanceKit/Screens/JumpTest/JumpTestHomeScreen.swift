//
//  JumpTestHomeScreen.swift
//  PerformanceKit
//
//  Created by Findlay Wood on 10/10/2026.
//
import SwiftUI

/// A jump test's home: the best as the screen's one big number, its power for
/// a test that estimates it, the latest beneath, then History and How It
/// Works, with Start Test pinned to the bottom. Start Test is absent when this
/// is someone else's centre.
struct JumpTestHomeScreen: View {

    @ObservedObject var viewModel: JumpTestHomeViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 8) {
                PerformanceSectionHeader(title: "Best")
                bestCard
                    .padding(.bottom, 16)

                PerformanceSectionHeader(title: "Tests")
                VStack(spacing: 0) {
                    PerformanceRow(icon: "list.bullet", title: "History", subtitle: "Every test you have done", showsDivider: true) {
                        viewModel.history()
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
        .navigationTitle(viewModel.kind.title)
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    private var bestCard: some View {
        if let best = viewModel.best, let attempt = best.best {
            let headline = viewModel.kind.headline(of: attempt)
            VStack(spacing: 4) {
                Text(headline.value)
                    .font(.system(size: 48, weight: .bold))
                    .foregroundStyle(Color.darkColor)
                + Text(" \(headline.unit)")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(Color.secondary)
                if let detail = viewModel.kind.detail(of: attempt) {
                    Text(detail)
                        .font(.system(size: 14, weight: .medium))
                }
                Text(dateLine(for: best))
                    .font(.system(size: 13))
                    .foregroundStyle(Color.secondary)
                if let power = best.power {
                    JumpPowerLine(power: power)
                        .padding(.top, 8)
                } else if viewModel.kind.estimatesPower {
                    Text("Log your weight in Profile to see power.")
                        .font(.system(size: 13))
                        .foregroundStyle(Color.secondary)
                        .padding(.top, 8)
                }
                if let latest = viewModel.latest, latest.id != best.id, let latestAttempt = latest.best {
                    Text("Latest \(viewModel.kind.headlineText(of: latestAttempt)), \(latest.date.formatted(.dateTime.day().month(.abbreviated)))")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(Color.secondary)
                        .padding(.top, 6)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .performanceCard()
        } else {
            PerformanceEmptyCard(message: "No tests recorded yet.", isLoading: viewModel.isLoading)
        }
    }

    private func dateLine(for session: JumpTestSession) -> String {
        let date = session.date.formatted(.dateTime.day().month(.wide).year())
        guard let box = session.boxHeight else { return date }
        return "\(date), off a \(Int(box)) cm box"
    }
}
