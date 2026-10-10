//
//  BalanceSessionScreen.swift
//  PerformanceKit
//
//  Created by Findlay Wood on 10/10/2026.
//
import SwiftUI

/// A sitting of the balance test: eyes open or closed, which leg is next, two
/// stand slots per leg with each leg's steadiest marked, the asymmetry once
/// both legs have a full stand, and Record / Save pinned to the bottom.
struct BalanceSessionScreen: View {

    @ObservedObject var viewModel: BalanceSessionViewModel
    @State private var isConfirmingCancel = false

    var body: some View {
        ScrollView {
            VStack(spacing: 8) {
                Text("Two stands on each leg, \(Int(BalanceAttempt.targetDuration)) seconds each. Your steadiest full stand on each leg, and the gap between them, is your result.")
                    .font(.system(size: 15))
                    .foregroundStyle(Color.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 4)
                    .padding(.bottom, 16)

                PerformanceSectionHeader(title: "Setup")
                VStack(alignment: .leading, spacing: 12) {
                    PerformancePillPicker(options: BalanceCondition.allCases, selection: $viewModel.condition) { $0.title }
                        // Fixed once the first stand is in: stands under
                        // different conditions would not make one result.
                        .disabled(!viewModel.attempts.isEmpty)
                    PerformancePillPicker(options: JumpSide.allCases, selection: $viewModel.selectedSide) { "\($0.title) leg" }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(12)
                .performanceCard()
                .padding(.bottom, 16)

                ForEach(JumpSide.allCases, id: \.self) { side in
                    PerformanceSectionHeader(title: "\(side.title) leg")
                    slots(on: side)
                        .padding(.bottom, 8)
                }

                if let symmetry = viewModel.symmetry {
                    BalanceSymmetryLine(symmetry: symmetry)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 4)
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
                    PerformancePrimaryButton(title: "Record \(viewModel.selectedSide.title.lowercased()) stand \(viewModel.attempts(on: viewModel.selectedSide).count + 1)") {
                        viewModel.recordStand()
                    }
                    if viewModel.canSave {
                        Button(viewModel.isSaving ? "Saving…" : "Save") {
                            Task { await viewModel.save() }
                        }
                        .font(.system(size: 15, weight: .semibold))
                        .tint(Color.darkColor)
                        .disabled(viewModel.isSaving)
                    }
                } else {
                    PerformancePrimaryButton(title: "Save", isEnabled: viewModel.canSave, isWorking: viewModel.isSaving) {
                        Task { await viewModel.save() }
                    }
                }
            }
        }
        .navigationTitle("Balance")
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
        .alert("Discard these stands?", isPresented: $isConfirmingCancel) {
            Button("Discard", role: .destructive) { viewModel.cancel() }
            Button("Keep Going", role: .cancel) {}
        } message: {
            Text("They haven't been saved.")
        }
        .interactiveDismissDisabled(!viewModel.attempts.isEmpty)
    }

    private func slots(on side: JumpSide) -> some View {
        let indices = viewModel.attempts.indices.filter { viewModel.attempts[$0].side == side }
        let bestIndex = viewModel.bestIndex(on: side)
        return VStack(spacing: 0) {
            ForEach(0..<BalanceSession.attemptsPerSide, id: \.self) { slot in
                let index = indices.indices.contains(slot) ? indices[slot] : nil
                BalanceAttemptRow(
                    number: slot + 1,
                    attempt: index.map { viewModel.attempts[$0] },
                    isBest: index != nil && index == bestIndex,
                    showsDivider: slot < BalanceSession.attemptsPerSide - 1,
                    onRemove: { if let index { viewModel.removeAttempt(at: index) } }
                )
            }
        }
        .performanceCard()
    }
}
