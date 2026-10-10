//
//  JumpResultsScreen.swift
//  PerformanceKit
//
//  Created by Findlay Wood on 10/10/2026.
//
import SwiftUI

/// The legacy `JumpResultsView`, moved as it was: the height with a cm / in
/// switch, then Save Jump, which turns into a spinner and then "Saved!".
struct JumpResultsScreen: View {

    @ObservedObject var viewModel: JumpResultsViewModel

    var body: some View {
        NavigationStack {
            List {
                Section("Result") {
                    HStack {
                        Spacer()
                        Text(viewModel.height, format: .number)
                            .font(.largeTitle.bold())
                        Text(viewModel.measurement.title)
                        Spacer()
                    }
                    .padding()
                    Picker("Select Measurement", selection: $viewModel.measurement) {
                        ForEach(JumpMeasurement.allCases, id: \.self) {
                            Text($0.title)
                        }
                    }
                    .pickerStyle(.segmented)
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
                    } else if viewModel.saveSucceeded {
                        HStack {
                            Spacer()
                            VStack {
                                Image(systemName: "checkmark.diamond.fill")
                                    .font(.title)
                                    .foregroundColor(Color.darkColor)
                                Text("Saved!")
                                    .font(.headline)
                                    .foregroundColor(Color.darkColor)
                            }
                            .padding()
                            Spacer()
                        }
                        .listRowBackground(Color.clear)
                    } else {
                        Button {
                            Task { await viewModel.save() }
                        } label: {
                            Text("Save Jump")
                        }
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.darkColor)
                        .cornerRadius(8)
                        .listRowBackground(Color.clear)
                    }
                }
            }
            .navigationTitle("Vertical Jump Results")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        viewModel.dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(Color.darkColor)
                    }
                }
            }
        }
    }
}
