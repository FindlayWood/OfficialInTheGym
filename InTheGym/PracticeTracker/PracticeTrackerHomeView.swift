//
//  PracticeTrackerHomeView.swift
//  InTheGym
//
//  Created by Findlay-Personal on 03/11/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Combine
import SwiftUI

struct PracticeTrackerHomeView: View {
    @StateObject var viewModel = PracticeTrackerViewModel()
    
    var tapped = PassthroughSubject<PracticeTrackerModel,Never>()
    var body: some View {
        List {
            /// top section to display info about match tracker
            Section {
                HStack {
                    Spacer()
                    VStack {
                        Image("circuit_icon")
                            .resizable()
                            .frame(width: 100, height: 100)
                        Text("Practice Tracker")
                            .font(.largeTitle.bold())
                            .foregroundColor(Color(.darkColour))
                        Text("Welcome to the practice tracker. Here you can record all of your practice sessions. (Do not record gym sessions here if you have entered them already)")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    Spacer()
                }
            }
            .listRowBackground(Color.clear)
            
            /// button to record new match
            Section {
                Button {
                    viewModel.isShowingNeMatchSheet = true
                } label: {
                    HStack {
                        Image("circuit_icon")
                            .resizable()
                            .frame(width: 30, height: 30)
                        Text("Record New Practice")
                            .font(.headline)
                    }
                    .padding(.vertical, 8)
                }
            } header: {
                Text("New Practice")
            }
            
            /// section to display previous matches
            Section {
                if viewModel.isLoading && viewModel.previousPracticeModels.isEmpty {
                    ProgressView()
                } else if viewModel.previousPracticeModels.isEmpty {
                    Text("No previous practice sessions.")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                } else {
                    ForEach(viewModel.previousPracticeModels, id: \.id) { model in
                        PracticeTrackerListView(model: model)
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                            .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
                            .onTapGesture {
                                tapped.send(model)
                            }
                    }
                }
                
            } header: {
                Text("Previous Practice Sessions")
            }
        }
        .sheet(isPresented: $viewModel.isShowingNeMatchSheet) {
            NewPracticeTrackerSheet(viewModel: viewModel)
        }
        .task {
            await viewModel.load()
        }
    }
}

struct PracticeTrackerHomeView_Previews: PreviewProvider {
    static var previews: some View {
        PracticeTrackerHomeView()
    }
}
