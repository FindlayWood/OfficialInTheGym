//
//  CMJMyJumpsView.swift
//  InTheGym
//
//  Created by Findlay Wood on 24/09/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import SwiftUI

struct CMJMyJumpsView: View {
    
    @StateObject var viewModel = ViewModel()
    
    var body: some View {
        List {
            Section {
                HStack(alignment: .bottom) {
                    VStack {
                        Text("SORT BY")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                        HStack {
                            Button {
                                withAnimation {
                                    viewModel.sortedByDate(true)
                                }
                            } label: {
                                Image(systemName: viewModel.sortedByDate ? "calendar.circle.fill" : "calendar.circle")
                                    .frame(width: 30, height: 30)
                                    .foregroundColor(Color(.darkColour))
                            }.buttonStyle(.borderless)
                            Button {
                                withAnimation {
                                    viewModel.sortedByDate(false)
                                }
                            } label: {
                                Image(systemName: !(viewModel.sortedByDate) ? "number.circle.fill" : "number.circle")
                                    .frame(width: 30, height: 30)
                                    .foregroundColor(Color(.darkColour))
                            }.buttonStyle(.borderless)
                        }
                    }
                    Spacer()
                    VStack {
                        Text("CONVERT TO")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                        Picker("Select Measurement", selection: $viewModel.measurement) {
                            ForEach(JumpMeasurement.allCases, id: \.self) {
                                Text($0.title)
                            }
                        }
                        .pickerStyle(.segmented)
                        .frame(maxWidth: 200)
                        .frame(height: 30)
                    }
                }
            }
            .listRowBackground(Color.clear)
            
            if viewModel.isLoading {
                ProgressView()
            } else if viewModel.jumpModels.isEmpty {
                Text("No Recorded CMJ Jumps")
                    .font(.footnote)
                    .foregroundColor(.secondary)
            } else {
                ForEach(viewModel.sortedModels) { model in
                    VStack {
                        HStack {
                            Text(model.date, format: .dateTime.day().month())
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                        }
                        HStack {
                            
                            VStack {
                                if viewModel.measurement == .cm {
                                    Text("\(model.height, specifier: "%.2f")cm")
                                        .font(.headline)
                                        .foregroundColor(Color(.darkColour))
                                } else {
                                    Text("\(model.height.convertCMtoInches(), specifier: "%.2f")in")
                                        .font(.headline)
                                        .foregroundColor(Color(.darkColour))
                                }
                                Text("Jump Height")
                            }
                            VStack {
                                Text(model.peakPower, format: .number)
                                    .font(.headline)
                                    .foregroundColor(Color(.darkColour))
                                Text("Peak Power")
                            }
                        }
                        .padding(.bottom)
                        VStack {
                            Text(model.fatigueLevel.title)
                                .font(.headline)
                            Text("Fatigue Level")
                        }
                    }
                }
            }
        }
        .task {
            await viewModel.loadModels()
        }
    }
}

struct CMJMyJumpsView_Previews: PreviewProvider {
    static var previews: some View {
        CMJMyJumpsView()
    }
}
