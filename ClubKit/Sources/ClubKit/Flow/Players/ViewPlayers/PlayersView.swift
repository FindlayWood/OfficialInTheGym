//
//  SwiftUIView.swift
//  
//
//  Created by Findlay-Personal on 24/05/2023.
//

import SwiftUI

struct PlayersView: View {
    
    @ObservedObject var viewModel: PlayersViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            if viewModel.isLoading {
                VStack {
                    Image(systemName: "network")
                        .font(.largeTitle)
                        .foregroundColor(Color(.darkColour))
                    Text("Loading Players")
                        .font(.title.bold())
                        .foregroundColor(Color(.darkColour))
                    Text("Wait 1 second, we are just loading your players!")
                        .font(.footnote.bold())
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding()
                    ProgressView()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(.secondarySystemBackground))
            } else {
                SearchBar(searchText: $viewModel.searchText, placeholder: "search players...")
                    .background(Capsule()
                        .foregroundColor(Color(.systemBackground)))
                
                if viewModel.searchedPlayers.isEmpty {
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
                        Text("No Players")
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
                            Text("No Players. Change your search term.")
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
                        Section {
                            ForEach(viewModel.searchedPlayers) { model in
                                PlayerRow(model: model, selectable: viewModel.selectable, selected: viewModel.checkSelection(of: model))
                                .onTapGesture {
                                    viewModel.tappedOn(model)
                                }
                            }
                        } header: {
                            Text("Players")
                        }
                    }
                    if viewModel.selectable {
                        Button {
                            viewModel.confirmSelectionAction()
                        } label: {
                            Text("Confirm Selection")
                                .padding()
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .background(Color(.darkColour))
                                .clipShape(Capsule())
                                .shadow(radius: 4)
                        }
                        .padding()
                    }
                }
            }
        }
        .background(Color(.systemBackground))
    }
}

struct PlayersView_Previews: PreviewProvider {
    class PreviewPlayerLoader: PlayerLoader {
        func loadAllPlayers(for teamID: String, in clubID: String) async throws -> [RemotePlayerModel] { return [] }
        func loadPlayer(with uid: String, from clubID: String) async throws -> RemotePlayerModel { return .example }
        func uploadNewPlayer(_ model: RemotePlayerModel, to teams: [String]) async throws {}
        func loadAllPlayers(for clubID: String) async throws -> [RemotePlayerModel] { return [] }
    }
    static var previews: some View {
        PlayersView(viewModel: PlayersViewModel(clubModel: .example, playerLoader: PreviewPlayerLoader()))
    }
}
