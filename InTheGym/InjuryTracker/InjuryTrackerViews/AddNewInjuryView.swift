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

    
    var body: some View {
        NavigationView {
            List {
                Section {
                    TextField("enter body part of injury", text: $viewModel.bodyPart)
                } header: {
                    Text("Body Part")
                } footer: {
                    Text("Enter the body part where your injury has occurred. Be specific - this helps you and your coaches/trainers.")
                }
                
                Section {
                    HStack {
                        TextField("estimated recovery time...", value: $viewModel.recoveryTime, format: .number)
                        Picker("Recovery Time", selection: $viewModel.recoveryTimeOptions) {
                            ForEach(RecoveryTimeOptions.allCases, id: \.self) { option in
                                Text(option.title)
                            }
                        }
                        .pickerStyle(.menu)
                    }
                    
                    Toggle("Send Notification", isOn: $viewModel.sendNotification)
                } header: {
                    Text("Recovery Time")
                } footer: {
                    Text("Enter the estimated recovery time in days for this injury. If send notification is on, we will send you a notification when the recovery time is up.")
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
                    } label: {
                        Text("Submit Injury Report")
                    }.disabled(viewModel.bodyPart == "")
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
