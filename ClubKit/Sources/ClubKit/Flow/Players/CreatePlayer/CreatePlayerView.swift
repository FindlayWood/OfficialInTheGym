//
//  SwiftUIView.swift
//  
//
//  Created by Findlay-Personal on 22/05/2023.
//

import SwiftUI

struct CreatePlayerView: View {
    
    @ObservedObject var viewModel: CreatePlayerViewModel
    
    var body: some View {
        ZStack {
            List {
                
                Section {
                    VStack(alignment: .leading) {
                        Text("Create New Player")
                            .font(.title3.bold())
                            .foregroundColor(.primary)
                        Text("Creating a new player will add them to them to the club. They can then be added and removed from team's within the club as you wish. If the player already has an InTheGym account then you can use QR code to add them immediately and they can get access theough their account. You can link created players with any InTheGym account at a later date.")
                            .font(.footnote.bold())
                            .foregroundColor(.secondary)
                    }
                }
                
                Section {
                    VStack(alignment: .leading) {
                        Text("Display Name")
                        TextField("enter display name...", text: $viewModel.displayName)
                    }
                } header: {
                    Text("Name")
                }
                
                Section {
                    ForEach(viewModel.teams, id: \.id) { model in
                        HStack {
                            Text(model.teamName)
                                .font(.headline)
                            Spacer()
                            Button {
                                viewModel.toggleSelectedTeam(model)
                            } label: {
                                Image(systemName: (viewModel.selectedTeams.contains(where: { $0.id == model.id })) ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(Color(.darkColour))
                            }
                        }
                    }
                } header: {
                    Text("Teams")
                }
                
                Section {
                    ForEach(viewModel.playerPositions, id: \.self) { position in
                        Text(position.title)
                    }
                    Menu {
                        ForEach(viewModel.selectedSport.positions, id: \.self) { position in
                            Button(position.rawValue) { viewModel.playerPositions.append(position)}
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(Color(.darkColour))
                    }
                } header: {
                    Text("All Positions")
                }
                
                Section {
                    Button {
                        Task {
                            await viewModel.create()
                        }
                    } label: {
                        Text("Create Player")
                            .padding()
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .background(Color(.darkColour).opacity(viewModel.buttonDisabled ? 0.3 : 1))
                            .clipShape(Capsule())
                            .shadow(radius: viewModel.buttonDisabled ? 0 : 4)
                    }
                    .disabled(viewModel.buttonDisabled)
                }
                .listRowBackground(Color.clear)
                .listRowInsets(.init(top: 2, leading: 2, bottom: 2, trailing: 2))
            }
            if viewModel.isUploading {
                ZStack {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                    RoundedRectangle(cornerRadius: 8)
                        .frame(width: 100, height: 100)
                        .foregroundColor(.white)
                    ProgressView()
                }
            }
            if viewModel.uploaded {
                ZStack {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                    VStack {
                        Image(systemName: "checkmark.circle.fill")
                            .resizable()
                            .frame(width: 70, height: 70)
                            .foregroundColor(.green)
                        Text("Created New Player")
                            .font(.headline)
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(4)
                }
            }
            if viewModel.errorUploading {
                ZStack {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                    VStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .resizable()
                            .frame(width: 70, height: 70)
                            .foregroundColor(.red)
                        Text("Error, please try again!")
                            .font(.headline)
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(4)
                }
            }
        }
        .onAppear {
            viewModel.loadTeams()
        }
    }
}

struct CreatePlayerView_Previews: PreviewProvider {
    private class PreviewPlayerLoader: PlayerLoader {
        func loadAllPlayers(for clubID: String) async throws -> [RemotePlayerModel] { return [] }
        func uploadNewPlayer(_ model: RemotePlayerModel, to teams: [String]) async throws {}
    }
    private class PreviewTeamLoader: TeamLoader {
        func loadAllTeams(for clubID: String) async throws -> [RemoteTeamModel] { return [] }
    }
    static var previews: some View {
        CreatePlayerView(viewModel: CreatePlayerViewModel(clubModel: .example, loader: PreviewPlayerLoader(), teamLoader: PreviewTeamLoader()))
    }
}
