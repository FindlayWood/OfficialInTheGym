//
//  NewMatchTrackerSheet.swift
//  InTheGym
//
//  Created by Findlay Wood on 08/10/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import SwiftUI

struct NewMatchTrackerSheet: View {
    @ObservedObject var viewModel: MatchTrackerViewModel
    @State var placeholder: String = "enter note..."
    @FocusState private var isNoteFocusses: Bool
    var body: some View {
        NavigationView {
            List {
                Section {
                    VStack {
                        Text("Enter some details about your match below. Most improtant is to rate your performance honestly. We will then calculate other data to show you.")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    
                }
                .listRowBackground(Color.clear)
                Section {
                    QuestionView(number: $viewModel.overallRating, title: "Rating", message: "How would you rate your performance?")
                } header: {
                    Text("Rate Your Overall Performance")
                }
                .disabled(viewModel.isUploading)
                Section {
                    QuestionView(number: $viewModel.technicalRating, title: "Technical Rating", message: "How would you rate your technical performance?")
                } header: {
                    Text("Physical")
                }
                .disabled(viewModel.isUploading)
                Section {
                    QuestionView(number: $viewModel.tacticalRating, title: "Tactical Rating", message: "How would you rate your tactical performance?")
                } header: {
                    Text("Technical")
                }
                .disabled(viewModel.isUploading)
                Section {
                    QuestionView(number: $viewModel.physicalRating, title: "Physical Rating", message: "How would you rate your physical performance?")
                } header: {
                    Text("Tactical")
                }
                .disabled(viewModel.isUploading)
                Section {
                    QuestionView(number: $viewModel.mentalRating, title: "Mental Rating", message: "How would you rate your mental performance?")
                } header: {
                    Text("Mental")
                }
                .disabled(viewModel.isUploading)
                
                Section {
                    VStack {
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
                                .focused($isNoteFocusses)
                        }
                        .frame(maxHeight: UIScreen.main.bounds.height * 0.8)
                        Spacer()
                    }
                } header: {
                    Text("Notes")
                }
                .disabled(viewModel.isUploading)
                
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        viewModel.isShowingNeMatchSheet = false
                    } label: {
                        Text("Dismiss")
                            .foregroundColor(Color(.darkColour))
                            .font(.body.bold())
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    if viewModel.isUploading {
                        ProgressView()
                    } else {
                        Button {
                            viewModel.upload()
                        } label: {
                            Image(systemName: "arrow.up.circle.fill")
                                .foregroundColor(Color(.darkColour))
                        }
                    }
                }
                ToolbarItem(placement: .keyboard) {
                    HStack {
                        Spacer()
                        Button("Done") {
                            isNoteFocusses = false
                        }
                    }
                }
            }
            .navigationTitle("New Match")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct NewMatchTrackerSheet_Previews: PreviewProvider {
    static var previews: some View {
        NewMatchTrackerSheet(viewModel: MatchTrackerViewModel())
    }
}
