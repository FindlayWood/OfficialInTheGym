//
//  CMJResultsView.swift
//  InTheGym
//
//  Created by Findlay Wood on 21/08/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import SwiftUI

struct CMJResultsView: View {
    
    @ObservedObject var viewModel: CMJResultsViewModel
    
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
                    if viewModel.loadingPower {
                        VStack {
                            HStack {
                                Spacer()
                                VStack {
                                    ProgressView()
                                    Text("Calculating Power...")
                                }
                                Spacer()
                            }
                        }
                    } else {
                        HStack {
                            Spacer()
                            VStack(spacing: 8) {
                                Text(viewModel.peakPower, format: .number)
                                    .font(.largeTitle.bold())
                                    .foregroundColor(.primary)
                                Text("Peak Power")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            VStack(spacing: 8) {
                                Text(viewModel.averagePower, format: .number)
                                    .font(.largeTitle.bold())
                                    .foregroundColor(.primary)
                                Text("Average Power")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                        }
                        .padding()
                    }
                } header: {
                    Text("Power Output")
                } footer: {
                    Text("Calculated power output from your last CMJ jump based on your height and weight.")
                }
                
                Section {
                    Text(viewModel.fatigueLevel.title)
                        .font(.headline)
                    Text(viewModel.fatigueLevel.message)
                        .font(.body)
                        .foregroundColor(.secondary)
                } header: {
                    Text("Fatigue")
                } footer: {
                    Text("Fatigue is calculated based on your most recent jump compared to your all time best jump.")
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
            .navigationTitle("CMJ Results")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(Color(.darkColour))
                    }
                    
                }
            }
            .onAppear {
                viewModel.calculatePower()
                viewModel.calculateFatigue()
            }
        }
    }
}

struct CMJResultsView_Previews: PreviewProvider {
    static var previews: some View {
        CMJResultsView(viewModel: CMJResultsViewModel())
    }
}
