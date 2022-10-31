//
//  PreviousJumpsView.swift
//  InTheGym
//
//  Created by Findlay-Personal on 31/10/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import SwiftUI

struct PreviousJumpsView: View {
    @StateObject private var viewModel = ViewModel()
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
            
            Section {
                ForEach(viewModel.sortedModels, id: \.time) { model in
                    VStack {
                        HStack {
                            Text(model.time, format: .dateTime.day().month())
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                        }
                        HStack {
                            Spacer()
                            if viewModel.measurement == .cm {
                                Text("\(model.height, specifier: "%.2f")cm")
                                    .font(.largeTitle.bold())
                                    .foregroundColor(Color(.darkColour))
                            } else {
                                Text("\(model.height.convertCMtoInches(), specifier: "%.2f")in")
                                    .font(.largeTitle.bold())
                                    .foregroundColor(Color(.darkColour))
                            }
                            Spacer()
                        }
                    }
                }
            } header: {
                HStack {
                    Text("Previous Jumps")
                }
                
            }
        }
        .task {
            await viewModel.loadModels()
        }
    }
}

struct PreviousJumpsView_Previews: PreviewProvider {
    static var previews: some View {
        PreviousJumpsView()
    }
}
