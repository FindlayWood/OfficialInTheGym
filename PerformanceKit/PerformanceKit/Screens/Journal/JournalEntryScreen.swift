//
//  JournalEntryScreen.swift
//  PerformanceKit
//
//  Created by Findlay Wood on 10/10/2026.
//
import SwiftUI

/// Writing a new entry: a full-height editor in a card, Cancel top left, and
/// Save as the bottom button, gated until there is more than three characters.
///
/// The legacy screen saved from a small arrow in the corner, faded to 30% when
/// disabled with nothing saying why, and drew its placeholder as a second,
/// disabled `TextEditor` behind the first.
struct JournalEntryScreen: View {

    @Environment(\.dismiss) private var dismiss
    @StateObject var viewModel: JournalEntryViewModel
    @FocusState private var isFocused: Bool
    let onAdded: (JournalEntry) -> Void

    init(viewModel: JournalEntryViewModel, onAdded: @escaping (JournalEntry) -> Void) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.onAdded = onAdded
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 8) {
                PerformanceSectionHeader(title: Date.now.formatted(.dateTime.weekday(.wide).day().month(.wide)))
                ZStack(alignment: .topLeading) {
                    if viewModel.entryText.isEmpty {
                        Text("How did today go?")
                            .font(.system(size: 16))
                            .foregroundStyle(Color(.placeholderText))
                            .padding(.horizontal, 5)
                            .padding(.vertical, 8)
                            .allowsHitTesting(false)
                    }
                    TextEditor(text: $viewModel.entryText)
                        .font(.system(size: 16))
                        .scrollContentBackground(.hidden)
                        .focused($isFocused)
                }
                .padding(12)
                .frame(maxHeight: .infinity)
                .performanceCard()
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .background(Color(.systemBackground).ignoresSafeArea())
            .performanceBottomBar {
                PerformancePrimaryButton(
                    title: "Save Entry",
                    isEnabled: viewModel.canUpload,
                    isWorking: viewModel.isUploading
                ) {
                    Task {
                        if let entry = try? await viewModel.upload() {
                            onAdded(entry)
                            dismiss()
                        }
                    }
                }
            }
            .navigationTitle("New Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                        .tint(Color.darkColor)
                }
            }
            .onAppear { isFocused = true }
        }
    }
}
