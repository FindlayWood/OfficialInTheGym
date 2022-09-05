//
//  TrainingStatusView.swift
//  InTheGym
//
//  Created by Findlay Wood on 07/08/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import SwiftUI

struct TrainingStatusView: View {
    @StateObject var viewModel = TrainingStatusViewModel()
    
    @State private var isShowingSheet = false
    @State private var currentStatus: AthleteStatus = .inSeason
    var body: some View {
        List {
            Section("Current Status") {
                if viewModel.isLoading {
                    ProgressView()
                } else {
                    VStack {
                        TrainingStatusRowView(status: viewModel.currentStatus)
                        Button {
                            isShowingSheet = true
                        } label: {
                            Text("Change Status")
                        }
                    }
                }
            }
            
            Section("Previous Updates") {
                ForEach(viewModel.previousChanges) { model in
                    VStack(alignment: .leading) {
                        Text(model.time, style: .date)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("Changed Status to \(model.status.title)")
                        
                    }
                    .padding()
                }
            }
        }
        .sheet(isPresented: $isShowingSheet) {
            if viewModel.isLoading {
                ProgressView()
            } else {
                UpdateTrainingStatusView(currentStatus: $viewModel.currentStatus, viewModel: viewModel)
            }
        }
        .task {
            await viewModel.loadModels()
        }
    }
}

struct TrainingStatusView_Previews: PreviewProvider {
    static var previews: some View {
        TrainingStatusView()
    }
}


