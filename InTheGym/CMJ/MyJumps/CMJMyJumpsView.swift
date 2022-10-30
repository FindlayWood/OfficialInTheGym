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
            if viewModel.isLoading {
                ProgressView()
            } else if viewModel.jumpModels.isEmpty {
                Text("No Recorded CMJ Jumps")
                    .font(.footnote)
                    .foregroundColor(.secondary)
            } else {
                ForEach(viewModel.jumpModels) { model in
                    VStack {
                        HStack {
                            Text(model.date, format: .dateTime.day().month())
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                        }
                        HStack {
                            VStack {
                                Text(model.height, format: .number)
                                    .font(.headline)
                                Text("Jump Height")
                            }
                            VStack {
                                Text(model.peakPower, format: .number)
                                    .font(.headline)
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
