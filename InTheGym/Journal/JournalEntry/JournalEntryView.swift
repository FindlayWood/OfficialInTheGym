//
//  JournalEntryView.swift
//  InTheGym
//
//  Created by Findlay Wood on 04/09/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import SwiftUI

struct JournalEntryView: View {
    @Environment(\.dismiss) var dismiss
    @State private var placeholder = "enter text..."
    @StateObject var viewModel = JournalEntryViewModel()
    var action: (JournalEntryModel) -> ()
    var body: some View {
        NavigationView {
            VStack {
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
                .frame(maxHeight: UIScreen.main.bounds.height * 0.3)
                Spacer()
            }
            .navigationTitle("Today's Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Dismiss")
                            .foregroundColor(Color(.darkColour))
                            .fontWeight(.bold)
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        Task {
                            do {
                                let newEntry = try await viewModel.uploadNewEntry()
                                action(newEntry)
                                dismiss()
                            }
                        }
                    } label: {
                        Image(systemName: "arrow.up.circle.fill")
                            .foregroundColor(viewModel.canUpload ? Color(.darkColour) : Color(.darkColour).opacity(0.3))
                    }
                    .disabled(!viewModel.canUpload)
                }
            }
        }
    }
}

struct JournalEntryView_Previews: PreviewProvider {
    static var previews: some View {
        JournalEntryView { model in
            
        }
    }
}
