//
//  NewTrackedSessionScreen.swift
//  PerformanceKit
//
//  Created by Findlay Wood on 10/10/2026.
//
import SwiftUI

/// Recording a match or practice: one card per question, notes, and Save as
/// the bottom button. A practice adds its RPE and duration first.
///
/// The legacy sheet was a default `List` with a segmented control per rating
/// and an upload arrow in the corner. Its section headers repeated the
/// question beneath them, so the questions carry their own headings now and the
/// sections are captioned by group.
struct NewTrackedSessionScreen: View {

    @StateObject var viewModel: NewTrackedSessionViewModel
    let onRecorded: (TrackedSession) -> Void

    @Environment(\.dismiss) private var dismiss
    @FocusState private var isNoteFocused: Bool

    init(viewModel: NewTrackedSessionViewModel, onRecorded: @escaping (TrackedSession) -> Void) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.onRecorded = onRecorded
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 8) {
                    Text(viewModel.kind.newEntryIntro)
                        .font(.system(size: 15))
                        .foregroundStyle(Color.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 4)
                        .padding(.bottom, 16)

                    if viewModel.kind.asksForRPEAndDuration {
                        PerformanceSectionHeader(title: "Session")
                        VStack(spacing: 10) {
                            RatingPicker(value: $viewModel.rpe, title: "RPE", message: "How hard was it? (RPE)")
                            durationCard
                        }
                        .padding(.bottom, 16)
                    }

                    PerformanceSectionHeader(title: "Your Performance")
                    VStack(spacing: 10) {
                        RatingPicker(value: $viewModel.ratings.overall, title: "Overall", message: "Overall")
                        RatingPicker(value: $viewModel.ratings.technical, title: "Technical", message: "Technical")
                        RatingPicker(value: $viewModel.ratings.tactical, title: "Tactical", message: "Tactical")
                        RatingPicker(value: $viewModel.ratings.physical, title: "Physical", message: "Physical")
                        RatingPicker(value: $viewModel.ratings.mental, title: "Mental", message: "Mental")
                    }
                    .padding(.bottom, 16)

                    PerformanceSectionHeader(title: "Notes")
                    ZStack(alignment: .topLeading) {
                        if viewModel.note.isEmpty {
                            Text("Anything worth remembering?")
                                .font(.system(size: 16))
                                .foregroundStyle(Color(.placeholderText))
                                .padding(.horizontal, 5)
                                .padding(.vertical, 8)
                                .allowsHitTesting(false)
                        }
                        TextEditor(text: $viewModel.note)
                            .font(.system(size: 16))
                            .scrollContentBackground(.hidden)
                            .focused($isNoteFocused)
                            .frame(minHeight: 120)
                    }
                    .padding(12)
                    .performanceCard()
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .disabled(viewModel.isUploading)
            }
            .scrollDismissesKeyboard(.interactively)
            .background(Color(.systemBackground).ignoresSafeArea())
            .performanceBottomBar {
                PerformancePrimaryButton(title: "Save", isWorking: viewModel.isUploading) {
                    Task {
                        if let session = try? await viewModel.save() {
                            onRecorded(session)
                        }
                    }
                }
            }
            .navigationTitle(viewModel.kind.newEntryTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                        .tint(Color.darkColor)
                }
                ToolbarItem(placement: .keyboard) {
                    HStack {
                        Spacer()
                        Button("Done") { isNoteFocused = false }
                            .tint(Color.darkColor)
                    }
                }
            }
        }
    }

    private var durationCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("How long was it?")
                .font(.system(size: 15, weight: .medium))
            HStack(spacing: 14) {
                stepButton("minus") { viewModel.duration = max(0, viewModel.duration - 5) }
                VStack(spacing: 6) {
                    Text("\(viewModel.duration, specifier: "%.0f") min")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(Color.darkColor)
                    Slider(value: $viewModel.duration, in: 0...240, step: 1)
                        .tint(Color.darkColor)
                }
                stepButton("plus") { viewModel.duration = min(240, viewModel.duration + 5) }
            }
        }
        .padding(16)
        .performanceCard()
    }

    private func stepButton(_ systemName: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Color.darkColor)
                .frame(width: 44, height: 44)
                .background(Circle().fill(Color(.tertiarySystemBackground)))
        }
        .buttonStyle(.plain)
    }
}
