//
//  AddNewInjuryView.swift
//  InTheGym
//
//  Created by Findlay Wood on 19/08/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import SwiftUI

struct AddNewInjuryView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: InjuryTrackerViewModel
    @FocusState private var isDescriptionFocussed: Bool
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    TextField("enter body part of injury", text: $viewModel.bodyPart)
                        .disabled(viewModel.uploading)
                } header: {
                    Text("Body Part")
                } footer: {
                    Text("Enter the body part where your injury has occurred. Be specific - this helps you and your coaches/trainers.")
                }
                Section {
                    VStack {
                        ZStack {
                            if viewModel.description.isEmpty {
                                TextEditor(text: $viewModel.placeholder)
                                    .font(.body.weight(.medium))
                                    .foregroundColor(Color(.tertiaryLabel))
                                    .disabled(true)
                                    .frame(height: 200)
                            }
                            TextEditor(text: $viewModel.description)
                                .font(.body.weight(.medium))
                                .opacity(viewModel.description.isEmpty ? 0.25 : 1)
                                .focused($isDescriptionFocussed)
                                .frame(height: 200)
                                .disabled(viewModel.uploading)
                        }
                        Spacer()
                    }
                } header: {
                    Text("Description")
                } footer: {
                    Text("Enter more detail about the injury, including how it occurred and where the pain is coming from.")
                }
                
                Section {
                    VStack {
                        TextField("estimated recovery time...", value: $viewModel.recoveryTime, format: .number)
                        Picker("Recovery Time", selection: $viewModel.recoveryTimeOptions) {
                            ForEach(RecoveryTimeOptions.allCases, id: \.self) { option in
                                Text(option.title)
                            }
                        }
                        .pickerStyle(.menu)
                    }
                } header: {
                    Text("Recovery Time")
                } footer: {
                    Text("Enter the estimated recovery time in days for this injury.")
                }
                
                Section {
                    Picker("Injury Severity", selection: $viewModel.severity) {
                        ForEach(InjurySeverity.allCases, id: \.self) { rank in
                            Text(rank.title)
                        }
                    }
                    .pickerStyle(.menu)
                } header: {
                    Text("Injury Severity")
                } footer: {
                    Text("Select the severity of this injury.")
                }
                
                Section {
                    Button {
                        viewModel.addNewInjury()
                        dismiss()
                    } label: {
                        Text("Submit Injury Report")
                    }
                    .disabled(viewModel.bodyPart == "" || viewModel.uploading)
                } header: {
                    Text("Submit")
                }
            }
            .navigationTitle("Add an Injury")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.body)
                            .foregroundColor(Color(.darkColour))
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    if viewModel.uploading {
                        ProgressView()
                    }
                }
                ToolbarItem(placement: .keyboard) {
                    HStack {
                        Spacer()
                        Button("Done") {
                            isDescriptionFocussed = false
                        }
                    }
                }
            }
        }
    }
}

struct AddNewInjuryView_Previews: PreviewProvider {
    static var previews: some View {
        AddNewInjuryView(viewModel: InjuryTrackerViewModel())
    }
}


enum RecoveryTimeOptions: String, CaseIterable {
    case days
    case weeks
    case months
    
    var title: String {
        switch self {
        case .days:
            return "Days"
        case .weeks:
            return "Weeks"
        case .months:
            return "Months"
        }
    }
}
