//
//  NewTrackedSessionScreen.swift
//  PerformanceKit
//
//  Created by Findlay Wood on 10/10/2026.
//
import SwiftUI

/// Recording a match or practice. The legacy `NewMatchTrackerSheet` and
/// `NewPracticeTrackerSheet`, one sheet now: a practice adds its RPE and
/// duration, and otherwise they were the same.
///
/// The section headers are the practice sheet's. The match sheet's had drifted,
/// with "Physical" over the technical question, "Technical" over the tactical
/// one and "Tactical" over the physical one.
struct NewTrackedSessionScreen: View {

    @StateObject var viewModel: NewTrackedSessionViewModel
    let onRecorded: (TrackedSession) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var placeholder = "enter note..."
    @FocusState private var isNoteFocused: Bool

    init(viewModel: NewTrackedSessionViewModel, onRecorded: @escaping (TrackedSession) -> Void) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.onRecorded = onRecorded
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Text(viewModel.kind.newEntryIntro)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .listRowBackground(Color.clear)

                if viewModel.kind.asksForRPEAndDuration {
                    Section {
                        RatingPicker(value: $viewModel.rpe, title: "RPE", message: "What was your session RPE?")
                    } header: {
                        Text("RPE")
                    }
                    .disabled(viewModel.isUploading)
                    Section {
                        durationStepper
                    } header: {
                        Text("Duration")
                    }
                    .disabled(viewModel.isUploading)
                }

                Section {
                    RatingPicker(value: $viewModel.ratings.overall, title: "Rating", message: "How would you rate your performance?")
                } header: {
                    Text("Rate Your Overall Performance")
                }
                .disabled(viewModel.isUploading)
                Section {
                    RatingPicker(value: $viewModel.ratings.technical, title: "Technical Rating", message: "How would you rate your technical performance?")
                } header: {
                    Text("Technical")
                }
                .disabled(viewModel.isUploading)
                Section {
                    RatingPicker(value: $viewModel.ratings.tactical, title: "Tactical Rating", message: "How would you rate your tactical performance?")
                } header: {
                    Text("Tactical")
                }
                .disabled(viewModel.isUploading)
                Section {
                    RatingPicker(value: $viewModel.ratings.physical, title: "Physical Rating", message: "How would you rate your physical performance?")
                } header: {
                    Text("Physical")
                }
                .disabled(viewModel.isUploading)
                Section {
                    RatingPicker(value: $viewModel.ratings.mental, title: "Mental Rating", message: "How would you rate your mental performance?")
                } header: {
                    Text("Mental")
                }
                .disabled(viewModel.isUploading)

                Section {
                    ZStack {
                        if viewModel.note.isEmpty {
                            TextEditor(text: $placeholder)
                                .font(.title3.weight(.medium))
                                .foregroundColor(.gray)
                                .disabled(true)
                        }
                        TextEditor(text: $viewModel.note)
                            .font(.title3.weight(.medium))
                            .opacity(viewModel.note.isEmpty ? 0.25 : 1)
                            .focused($isNoteFocused)
                    }
                    .frame(minHeight: 160)
                } header: {
                    Text("Notes")
                }
                .disabled(viewModel.isUploading)
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Dismiss")
                            .foregroundColor(Color.darkColor)
                            .font(.body.bold())
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    if viewModel.isUploading {
                        ProgressView()
                    } else {
                        Button {
                            Task {
                                if let session = try? await viewModel.save() {
                                    onRecorded(session)
                                }
                            }
                        } label: {
                            Image(systemName: "arrow.up.circle.fill")
                                .foregroundColor(Color.darkColor)
                        }
                    }
                }
                ToolbarItem(placement: .keyboard) {
                    HStack {
                        Spacer()
                        Button("Done") { isNoteFocused = false }
                    }
                }
            }
            .navigationTitle(viewModel.kind.newEntryTitle)
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var durationStepper: some View {
        HStack {
            Button {
                viewModel.duration = max(0, viewModel.duration - 1)
            } label: {
                Image(systemName: "minus.circle.fill")
                    .foregroundColor(Color.darkColor)
            }
            .buttonStyle(.borderless)
            VStack {
                Text("\(viewModel.duration, specifier: "%.0f") mins")
                    .font(.headline)
                Slider(value: $viewModel.duration, in: 0...240, step: 1)
                    .tint(Color.darkColor)
            }
            Button {
                viewModel.duration = min(240, viewModel.duration + 1)
            } label: {
                Image(systemName: "plus.circle.fill")
                    .foregroundColor(Color.darkColor)
            }
            .buttonStyle(.borderless)
        }
    }
}
