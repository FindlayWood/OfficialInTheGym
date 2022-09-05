//
//  CMJHomeViewSwiftUI.swift
//  InTheGym
//
//  Created by Findlay Wood on 27/08/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import SwiftUI

struct CMJHomeViewSwiftUI: View {
    
    @ObservedObject var viewModel: CMJHomeViewModel
    
    var body: some View {
        List {
            HStack {
                Spacer()
                VStack {
                    Image("bolt_icon")
                        .resizable()
                        .frame(width: 60, height: 60)
                    Text("CMJ (counter movement jump) is where you can measure your current lower body power output.")
                        .font(.body.weight(.medium))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                Spacer()
            }
            .listRowBackground(Color.clear)
            
            Section {
                if viewModel.isLoading {
                    VStack {
                        HStack {
                            Spacer()
                            VStack {
                                ProgressView()
                                Text("Loading...")
                                    .foregroundColor(Color(.darkColour))
                            }
                            Spacer()
                        }
                    }
                } else {
                    if let model = viewModel.recentModel {
                        VStack(spacing: 16) {
                            HStack {
                                Spacer()
                                VStack {
                                    Text(model.fatigueLevel.title)
                                        .font(.headline)
                                    Text("Fatigue Level")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                            }
                            HStack {
                                Spacer()
                                VStack {
                                    Text(model.peakPower, format: .number)
                                        .font(.title.bold())
                                        .foregroundColor(.primary)
                                    Text("Power")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                            }
                            Divider()
                            HStack {
                                Text(model.mostRecentData, format: .dateTime.day().month().year())
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Spacer()
                            }
                        }
                    } else {
                        Text("No Jumps Saved")
                    }
                }
            } header: {
                Text("Most Recent Jump")
            }
            
            if !viewModel.isLoading {
                Section {
                    Button {
                        viewModel.action(.recordNewJump)
                    } label: {
                        Text("Record New Jump")
                    }
                }
            }
            
            Section {
                Button {
                    viewModel.action(.myJumps)
                } label: {
                    Text("My Jumps")
                }
            }
            
            Section {
                Button {
                    viewModel.action(.myMeasurements)
                } label: {
                    HStack {
                        Text("My Measurements")
                        if measurementsModel {
                            Image(systemName: "exclamationmark.circle.fill")
                                .foregroundColor(.red)
                        }
                    }
                }
            }
        }
        .task {
            await viewModel.loadRecentResult()
            await viewModel.loadMeasurements()
        }
    }
    
    var measurementsModel: Bool {
        viewModel.measurementsModel == nil
    }
}

struct CMJHomeViewSwiftUI_Previews: PreviewProvider {
    static var previews: some View {
        CMJHomeViewSwiftUI(viewModel: CMJHomeViewModel())
    }
}
