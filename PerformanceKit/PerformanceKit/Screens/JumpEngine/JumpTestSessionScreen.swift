//
//  JumpTestSessionScreen.swift
//  PerformanceKit
//
//  Created by Findlay Wood on 10/10/2026.
//
import SwiftUI

/// A sitting of a jump test: a row per attempt, filled as each is measured,
/// the best marked, and the next action pinned to the bottom. "Record
/// attempt N" until three are in, then "Save". Save is also offered early, as
/// a quiet button, once there is one attempt.
struct JumpTestSessionScreen: View {

    @ObservedObject var viewModel: JumpTestSessionViewModel
    @State private var isConfirmingCancel = false

    var body: some View {
        ScrollView {
            VStack(spacing: 8) {
                Text("Best of \(viewModel.kind.attempts). Record each jump, tag it, and the highest is your result.")
                    .font(.system(size: 15))
                    .foregroundStyle(Color.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 4)
                    .padding(.bottom, 16)

                HStack {
                    PerformanceSectionHeader(title: "Attempts")
                    PerformancePillPicker(options: JumpMeasurement.allCases, selection: $viewModel.measurement) { $0.title }
                }
                VStack(spacing: 0) {
                    ForEach(0..<viewModel.kind.attempts, id: \.self) { index in
                        JumpAttemptRow(
                            number: index + 1,
                            attempt: viewModel.attempts.indices.contains(index) ? viewModel.attempts[index] : nil,
                            isBest: viewModel.bestIndex == index,
                            measurement: viewModel.measurement,
                            showsDivider: index < viewModel.kind.attempts - 1,
                            onRemove: { viewModel.removeAttempt(at: index) }
                        )
                    }
                }
                .performanceCard()

                if viewModel.kind.estimatesPower {
                    Group {
                        if let power = viewModel.bestPower {
                            JumpPowerLine(power: power)
                        } else if viewModel.bodyMass == nil {
                            Text("Log your weight in Profile to see power.")
                                .font(.system(size: 13))
                                .foregroundStyle(Color.secondary)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 4)
                    .padding(.top, 8)
                }

                if let error = viewModel.saveError {
                    Text(error)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(Color.red)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 4)
                        .padding(.top, 8)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
        }
        .background(Color(.systemBackground).ignoresSafeArea())
        .performanceBottomBar {
            VStack(spacing: 12) {
                if viewModel.canRecordMore {
                    PerformancePrimaryButton(title: "Record attempt \(viewModel.attempts.count + 1)") {
                        viewModel.recordAttempt()
                    }
                    if viewModel.canSave {
                        Button(viewModel.isSaving ? "Saving…" : "Save with \(viewModel.attempts.count)") {
                            Task { await viewModel.save() }
                        }
                        .font(.system(size: 15, weight: .semibold))
                        .tint(Color.darkColor)
                        .disabled(viewModel.isSaving)
                    }
                } else {
                    PerformancePrimaryButton(title: "Save", isWorking: viewModel.isSaving) {
                        Task { await viewModel.save() }
                    }
                }
            }
        }
        .navigationTitle(viewModel.kind.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Cancel") {
                    if viewModel.attempts.isEmpty {
                        viewModel.cancel()
                    } else {
                        isConfirmingCancel = true
                    }
                }
                .tint(Color.darkColor)
            }
        }
        .alert("Discard these jumps?", isPresented: $isConfirmingCancel) {
            Button("Discard", role: .destructive) { viewModel.cancel() }
            Button("Keep Going", role: .cancel) {}
        } message: {
            Text("They haven't been saved.")
        }
        .interactiveDismissDisabled(!viewModel.attempts.isEmpty)
        .task {
            await viewModel.loadBodyMass()
        }
    }
}
