//
//  SwiftUIView.swift
//  
//
//  Created by Findlay Wood on 01/10/2023.
//

import SwiftUI

struct CreateTeamView: View {
    
    @ObservedObject var viewModel: CreateTeamViewModel
    
    var body: some View {
        ZStack {
            List {
                
                Section {
                    VStack(alignment: .leading) {
                        Text("Display Name")
                            .font(.headline)
                            .foregroundStyle(Color.primary)
                        TextField("enter team name...", text: $viewModel.displayName)
                    }
                    .padding()
                    .background(
                        LinearGradient(colors: [Color(.offWhiteColour), .white], startPoint: .topLeading, endPoint: .bottomTrailing)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .shadow(color: .black.opacity(0.3), radius: 4, y: 4)
                    )
                    .padding(.bottom)
                    .padding(.horizontal, 4)
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets())
                }
                
                
                Section {
                    Button {
                        Task {
                            await viewModel.create()
                        }
                    } label: {
                        Text("Create Team")
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
                        Text("Created New Team")
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
        .task {
            await viewModel.loadPlayers()
        }
    }
}

struct CreateTeamView_Previews: PreviewProvider {
    private class PreviewPlayerLoader: PlayerLoader {
        func loadAllPlayers(for teamID: String, in clubID: String) async throws -> [RemotePlayerModel] { return [] }
        func loadPlayer(with uid: String, from clubID: String) async throws -> RemotePlayerModel { return .example }
        func loadAllPlayers(for clubID: String) async throws -> [RemotePlayerModel] { return [] }
        func uploadNewPlayer(_ model: RemotePlayerModel, to teams: [String]) async throws {}
    }
    private class PreviewService: TeamCreationService {
        func createNewTeam(with data: NewTeamData) async -> Result<NewTeamData, RemoteTeamCreationService.Error> {
            return .failure(.failed)
        }
    }
    static var previews: some View {
        CreateTeamView(viewModel: CreateTeamViewModel(playerLoader: PreviewPlayerLoader(), teamCreationService: PreviewService(), clubModel: .example))
    }
}
