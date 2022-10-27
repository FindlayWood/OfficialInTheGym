//
//  MatchTrackerView.swift
//  InTheGym
//
//  Created by Findlay Wood on 08/10/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Combine
import SwiftUI

struct MatchTrackerView: View {
    @StateObject var viewModel = MatchTrackerViewModel()
    
    var tapped = PassthroughSubject<MatchTrackerModel,Never>()
    var body: some View {
        List {
            /// top section to display info about match tracker
            Section {
                HStack {
                    Spacer()
                    VStack {
                        Image("contest_icon")
                            .resizable()
                            .frame(width: 100, height: 100)
                        Text("Match Tracker")
                            .font(.largeTitle.bold())
                            .foregroundColor(Color(.darkColour))
                        Text("Welcome to the match tracker. Here you can record all of your matches/games/competitions.")
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
                        Image("match_icon")
                            .resizable()
                            .frame(width: 30, height: 30)
                        Text("Record New Match")
                            .font(.headline)
                    }
                    .padding(.vertical, 12)
                }
            } header: {
                Text("New Match")
            }
            
            /// section to display previous matches
            Section {
                if viewModel.isLoading && viewModel.previousMatchModels.isEmpty {
                    ProgressView()
                } else if viewModel.previousMatchModels.isEmpty {
                    Text("No previous matches.")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                } else {
                    ForEach(viewModel.previousMatchModels, id: \.id) { model in
                        MatchTrackerListView(model: model)
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                            .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
                            .onTapGesture {
                                tapped.send(model)
                            }
                    }
                }
                
            } header: {
                Text("Previous Matches")
            }
        }
        .sheet(isPresented: $viewModel.isShowingNeMatchSheet) {
            NewMatchTrackerSheet(viewModel: viewModel)
        }
        .task {
            await viewModel.load()
        }
    }
}

struct MatchTrackerView_Previews: PreviewProvider {
    static var previews: some View {
        MatchTrackerView()
    }
}
