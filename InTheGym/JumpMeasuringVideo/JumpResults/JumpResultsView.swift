//
//  JumpResultsView.swift
//  InTheGym
//
//  Created by Findlay Wood on 21/08/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import SwiftUI

struct JumpResultsView: View {
    
    @ObservedObject var viewModel: JumpResultsViewModel
    
    var body: some View {
        NavigationView {
            List {
                Section("Result") {
                    HStack {
                        Spacer()
                        Text(viewModel.height, format: .number)
                            .font(.largeTitle.bold())
                        Text(viewModel.measurements.title)
                        Spacer()
                    }
                    .padding()
                    Picker("Select Measurement", selection: $viewModel.measurements) {
                        ForEach(JumpMeasurement.allCases, id: \.self) {
                            Text($0.title)
                        }
                    }
                    .pickerStyle(.segmented)
                    .onChange(of: viewModel.measurements) { newValue in
                        switch newValue {
                        case .cm:
                            viewModel.convertToCM()
                        case .inches:
                            viewModel.convertToInches()
                        }
                    }
                }
                
                Section {
                    
                    if viewModel.isSaving {
                        HStack {
                            Spacer()
                            VStack {
                                ProgressView()
                                Text("Saving Result...")
                            }
                            .padding()
                            Spacer()
                        }
                        .listRowBackground(Color.clear)
                    } else {
                        if viewModel.saveSucces {
                            HStack {
                                Spacer()
                                VStack {
                                    Image(systemName: "checkmark.diamond.fill")
                                        .font(.title)
                                        .foregroundColor(Color(.darkColour))
                                    Text("Saved!")
                                        .font(.headline)
                                        .foregroundColor(Color(.darkColour))
                                }
                                .padding()
                                Spacer()
                            }
                            .listRowBackground(Color.clear)
                        } else {
                            Button {
                                viewModel.saveResult()
                            } label: {
                                Text("Save Jump")
                            }
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color(.darkColour))
                            .cornerRadius(8)
                            .listRowBackground(Color.clear)
                        }
                    }
                }
            }
            .navigationTitle("Vertical Jump Results")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        viewModel.dismissAction()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(Color(.darkColour))
                    }
                    
                }
            }
        }
    }
}

struct JumpResultsView_Previews: PreviewProvider {
    static var previews: some View {
        JumpResultsView(viewModel: JumpResultsViewModel())
    }
}
