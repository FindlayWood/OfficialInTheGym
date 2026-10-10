//
//  JournalEntryScreen.swift
//  PerformanceKit
//
//  Created by Findlay Wood on 10/10/2026.
//
import SwiftUI

/// Writing a new entry. The legacy `JournalEntryView`, moved as it was: a
/// full-screen editor with Dismiss on the left and an upload arrow on the
/// right, which turns into a spinner while saving.
struct JournalEntryScreen: View {

    @Environment(\.dismiss) private var dismiss
    @State private var placeholder = "enter text..."
    @StateObject var viewModel: JournalEntryViewModel
    let onAdded: (JournalEntry) -> Void

    init(viewModel: JournalEntryViewModel, onAdded: @escaping (JournalEntry) -> Void) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.onAdded = onAdded
    }

    var body: some View {
        NavigationStack {
            ZStack {
                if viewModel.entryText.isEmpty {
                    TextEditor(text: $placeholder)
                        .font(.title3.weight(.medium))
                        .foregroundColor(.gray)
                        .disabled(true)
                        .padding()
                }
                TextEditor(text: $viewModel.entryText)
                    .font(.title3.weight(.medium))
                    .opacity(viewModel.entryText.isEmpty ? 0.25 : 1)
                    .padding()
            }
            .frame(maxHeight: .infinity, alignment: .top)
            .navigationTitle("New Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Dismiss")
                            .foregroundColor(Color.darkColor)
                            .fontWeight(.bold)
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    if viewModel.isUploading {
                        ProgressView()
                    } else {
                        Button {
                            Task {
                                if let entry = try? await viewModel.upload() {
                                    onAdded(entry)
                                    dismiss()
                                }
                            }
                        } label: {
                            Image(systemName: "arrow.up.circle.fill")
                                .foregroundColor(viewModel.canUpload ? Color.darkColor : Color.darkColor.opacity(0.3))
                        }
                        .disabled(!viewModel.canUpload)
                    }
                }
            }
        }
    }
}
