//
//  BalanceHistoryScreen.swift
//  PerformanceKit
//
//  Created by Findlay Wood on 10/10/2026.
//
import SwiftUI

/// Every balance session, newest first: date and condition, then each leg's
/// sway and the gap. It reads the sessions the home already loaded, so it
/// needs no loader of its own.
struct BalanceHistoryScreen: View {

    @ObservedObject var viewModel: BalanceHomeViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 8) {
                PerformanceSectionHeader(title: "Tests")
                let sessions = viewModel.sessions.sorted { $0.date > $1.date }
                if sessions.isEmpty {
                    PerformanceEmptyCard(message: "No tests saved yet.", isLoading: viewModel.isLoading)
                } else {
                    VStack(spacing: 0) {
                        ForEach(Array(sessions.enumerated()), id: \.element.id) { index, session in
                            row(session, showsDivider: index < sessions.count - 1)
                        }
                    }
                    .performanceCard()
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
        }
        .background(Color(.systemBackground).ignoresSafeArea())
        .navigationTitle("Balance History")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func row(_ session: BalanceSession, showsDivider: Bool) -> some View {
        VStack(spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(session.date, format: .dateTime.day().month(.abbreviated).year())
                        .font(.system(size: 15, weight: .medium))
                    Text(session.condition.title)
                        .font(.system(size: 12))
                        .foregroundStyle(Color.secondary)
                }
                Spacer()
                if let symmetry = session.symmetry {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("L \(format(symmetry.left)) · R \(format(symmetry.right)) mg")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(Color.darkColor)
                        Text(symmetry.summary)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(symmetry.isNotable ? Color.matteAmber : Color.secondary)
                    }
                } else {
                    Text("Incomplete")
                        .font(.system(size: 14))
                        .foregroundStyle(Color.secondary)
                }
            }
            .padding(.horizontal, 16)
            .frame(minHeight: 56)
            if showsDivider {
                Divider().padding(.leading, 16)
            }
        }
    }

    private func format(_ value: Double) -> String {
        value.formatted(.number.precision(.fractionLength(1)))
    }
}
