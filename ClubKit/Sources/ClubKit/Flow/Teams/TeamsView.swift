//
//  SwiftUIView.swift
//  
//
//  Created by Findlay-Personal on 21/05/2023.
//

import SwiftUI

struct TeamsView: View {
    
    @ObservedObject var viewModel: TeamsViewModel
    
    var body: some View {
        VStack {
            if viewModel.isLoading {
                VStack {
                    Image(systemName: "network")
                        .font(.largeTitle)
                        .foregroundColor(Color(.darkColour))
                    Text("Loading Teams")
                        .font(.title.bold())
                        .foregroundColor(Color(.darkColour))
                    Text("Wait 1 second, we are just loading your teams!")
                        .font(.footnote.bold())
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding()
                    ProgressView()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(.secondarySystemBackground))
            } else {
                if viewModel.teams.isEmpty {
                    VStack {
                        ZStack {
                            Image(systemName: "person.3.fill")
                                .font(.largeTitle)
                                .foregroundColor(Color(.darkColour))
                            Image(systemName: "nosign")
                                .resizable()
                                .frame(width: 80, height: 80)
                                .foregroundColor(.red.opacity(0.5))
                        }
                        Text("No Teams")
                            .font(.title.bold())
                            .foregroundColor(Color(.darkColour))
                        Text("This club currently has not teams. You can create a team for this club. Once you have created a team it will appear here.")
                            .font(.footnote.bold())
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding()
                        Button {
                            
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .resizable()
                                .frame(width: 50, height: 50)
                                .foregroundColor(Color(.darkColour).opacity(0.8))
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(.secondarySystemBackground))
                } else {
                    List {
                        ForEach(viewModel.teams) { model in
//                            Section {
                                TeamRow(model: model)
//                            }
                        }
                        .listRowBackground(Color.clear)
                        .listRowInsets(EdgeInsets(top: 1, leading: 1, bottom: 1, trailing: 1))
                        .padding(.bottom)
                    }
                }
            }
        }
        .task {
            await viewModel.load()
        }
    }
}

struct TeamsView_Previews: PreviewProvider {
    
    private class PreviewTeamLoader: TeamLoader {
        func loadAllTeams(for clubID: String) async throws -> [RemoteTeamModel] {
            return []
        }
    }
    
    static var previews: some View {
        TeamsView(viewModel: TeamsViewModel(clubModel: .example, teamLoader: PreviewTeamLoader()))
    }
}
