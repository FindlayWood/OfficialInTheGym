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
                    SearchBar(searchText: $viewModel.searchText, placeholder: "search teams...")
                        .background(Capsule()
                            .foregroundColor(Color(.systemBackground)))
                    
                    if viewModel.searchedTeams.isEmpty {
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
                            if viewModel.searchText.isEmpty {
                                Text("This club currently has no players. You can create a team for this club. Once you have created a team it will appear here.")
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
                            } else {
                                Text("No Teams. Change your search term.")
                                    .font(.footnote.bold())
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                                    .padding()
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color(.secondarySystemBackground))
                    } else {
                        List {
                            ForEach(viewModel.teams) { model in
                                Button {
                                    viewModel.selectedTeamAction(model)
                                } label: {
                                    TeamRow(model: model)
                                }
                            }
                            .listRowBackground(Color.clear)
                            .listRowInsets(EdgeInsets(top: 1, leading: 1, bottom: 1, trailing: 1))
                            .padding(.bottom)
                        }
                    }
                }
            }
        }
        .background(Color(.systemBackground))
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
        func loadTeam(with teamID: String, from clubID: String) async throws -> RemoteTeamModel {
            return .example
        }
    }
    
    static var previews: some View {
        TeamsView(viewModel: TeamsViewModel(clubModel: .example, teamLoader: PreviewTeamLoader()))
    }
}
