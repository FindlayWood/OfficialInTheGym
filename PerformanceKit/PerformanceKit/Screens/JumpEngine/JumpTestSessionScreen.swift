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

    /// The slots for one leg, or for the whole test when it is two-legged.
    /// Each slot maps to its attempt's position in `attempts`, which is what
    /// removal and the best marker work on.
    private func attemptSlots(on side: JumpSide?) -> some View {
        let indices = viewModel.attempts.indices.filter { side == nil || viewModel.attempts[$0].side == side }
        let bestIndex = side.map { viewModel.bestIndex(on: $0) } ?? viewModel.bestIndex
        return VStack(spacing: 0) {
            ForEach(0..<viewModel.kind.attempts, id: \.self) { slot in
                let index = indices.indices.contains(slot) ? indices[slot] : nil
                JumpAttemptRow(
                    number: slot + 1,
                    kind: viewModel.kind,
                    attempt: index.map { viewModel.attempts[$0] },
                    isBest: index != nil && index == bestIndex,
                    measurement: viewModel.measurement,
                    showsDivider: slot < viewModel.kind.attempts - 1,
                    onRemove: { if let index { viewModel.removeAttempt(at: index) } }
                )
            }
        }
        .performanceCard()
    }

    private var recordTitle: String {
        if viewModel.isSided {
            return "Record \(viewModel.selectedSide.title.lowercased()) attempt \(viewModel.attempts(on: viewModel.selectedSide).count + 1)"
        }
        return "Record attempt \(viewModel.attempts.count + 1)"
    }

    private var intro: String {
        switch viewModel.kind.headline {
        case .height where viewModel.isSided:
            "Up to \(viewModel.kind.attempts) on each leg. Your best on each, and the gap between them, is your result."
        case .height:
            "Best of \(viewModel.kind.attempts). Record each jump, tag it, and the highest is your result."
        case .reactiveStrength where viewModel.kind == .repeatedJumps:
            "Best of \(viewModel.kind.attempts). Each attempt is ten hops. Your RSI is the average of your best five rebounds."
        case .reactiveStrength:
            "Best of \(viewModel.kind.attempts). Pick your box, then record each jump and tag it. Your best RSI is your result."
        }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 8) {
                Text(intro)
                    .font(.system(size: 15))
                    .foregroundStyle(Color.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 4)
                    .padding(.bottom, 16)

                if viewModel.kind.usesBoxHeight {
                    PerformanceSectionHeader(title: "Box Height")
                    HStack {
                        PerformancePillPicker(options: JumpTestSessionViewModel.boxHeights, selection: $viewModel.boxHeight) {
                            "\(Int($0)) cm"
                        }
                        Spacer(minLength: 0)
                    }
                    .padding(12)
                    .performanceCard()
                    // Fixed once the first attempt is in: attempts off
                    // different boxes would not make one result.
                    .disabled(!viewModel.attempts.isEmpty)
                    .padding(.bottom, 16)
                }

                if viewModel.isSided {
                    PerformanceSectionHeader(title: "Recording")
                    HStack {
                        PerformancePillPicker(options: viewModel.kind.sides, selection: $viewModel.selectedSide) { "\($0.title) leg" }
                        Spacer(minLength: 0)
                    }
                    .padding(12)
                    .performanceCard()
                    .padding(.bottom, 16)

                    ForEach(viewModel.kind.sides, id: \.self) { side in
                        HStack {
                            PerformanceSectionHeader(title: "\(side.title) leg")
                            if side == viewModel.kind.sides.first {
                                PerformancePillPicker(options: JumpMeasurement.allCases, selection: $viewModel.measurement) { $0.title }
                            }
                        }
                        attemptSlots(on: side)
                            .padding(.bottom, 8)
                    }

                    if let symmetry = viewModel.symmetry {
                        JumpSymmetryLine(symmetry: symmetry)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 4)
                    }
                } else {
                    HStack {
                        PerformanceSectionHeader(title: "Attempts")
                        PerformancePillPicker(options: JumpMeasurement.allCases, selection: $viewModel.measurement) { $0.title }
                    }
                    attemptSlots(on: nil)
                }

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
                    PerformancePrimaryButton(title: recordTitle) {
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
