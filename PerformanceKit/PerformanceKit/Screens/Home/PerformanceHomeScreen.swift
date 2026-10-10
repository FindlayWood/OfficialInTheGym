//
//  PerformanceHomeScreen.swift
//  PerformanceKit
//
//  Created by Findlay Wood on 10/10/2026.
//
import SwiftUI

/// The PERFORMANCE tab: every tool as a row in one card, under a line saying
/// what the tab is for.
///
/// It used to be the legacy Performance Center: a 100pt icon, a paragraph,
/// and a white shadowed card per tool over a gradient into the premium colour.
/// It is on MyDay's vocabulary now, a `systemBackground` page with a
/// `secondarySystemBackground` card, so the tab reads as part of the app
/// rather than a different one.
struct PerformanceHomeScreen: View {

    let viewModel: PerformanceHomeViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 8) {
                Text("Tools for tracking how you train, compete and recover.")
                    .font(.system(size: 15))
                    .foregroundStyle(Color.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 4)
                    .padding(.bottom, 16)

                PerformanceSectionHeader(title: "Tools")
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
        .navigationTitle("Performance")
        .navigationBarTitleDisplayMode(.large)
    }
}

#Preview {
    NavigationStack {
        PerformanceHomeScreen(viewModel: PerformanceHomeViewModel(currentUserId: "a", athleteId: "a"))
    }
}
