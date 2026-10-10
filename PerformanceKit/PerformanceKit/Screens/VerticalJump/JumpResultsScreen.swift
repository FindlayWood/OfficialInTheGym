//
//  JumpResultsScreen.swift
//  PerformanceKit
//
//  Created by Findlay Wood on 10/10/2026.
//
import SwiftUI

/// A measured jump: the height large, a cm / in switch, and Save Jump as the
/// bottom button, which becomes a spinner and then a "Saved" confirmation.
struct JumpResultsScreen: View {

    @ObservedObject var viewModel: JumpResultsViewModel

    var body: some View {
        NavigationStack {
            VStack(spacing: 8) {
                PerformanceSectionHeader(title: "Your Jump")
                VStack(spacing: 16) {
                    (Text(viewModel.height, format: .number.precision(.fractionLength(0...2)))
                        .font(.system(size: 56, weight: .bold))
                        .foregroundStyle(Color.darkColor)
                     + Text(" \(viewModel.measurement.title)")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(Color.secondary))
                    PerformancePillPicker(options: JumpMeasurement.allCases, selection: $viewModel.measurement) { $0.title }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 28)
                .performanceCard()
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .background(Color(.systemBackground).ignoresSafeArea())
            .performanceBottomBar {
                if viewModel.saveSucceeded {
                    Label("Saved", systemImage: "checkmark.circle.fill")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Color.darkColor)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                } else {
                    PerformancePrimaryButton(title: "Save Jump", isWorking: viewModel.isSaving) {
                        Task { await viewModel.save() }
                    }
                }
            }
            .navigationTitle("Result")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { viewModel.dismiss() }
                        .fontWeight(.semibold)
                        .tint(Color.darkColor)
                }
            }
        }
    }
}
