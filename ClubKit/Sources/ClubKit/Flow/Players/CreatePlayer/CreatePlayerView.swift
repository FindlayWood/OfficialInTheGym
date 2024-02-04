//
//  SwiftUIView.swift
//  
//
//  Created by Findlay-Personal on 22/05/2023.
//

import PhotosUI
import SwiftUI

struct CreatePlayerView: View {
    
    @ObservedObject var viewModel: CreatePlayerViewModel
    
    @State private var selectedPhotos: [PhotosPickerItem] = []
    @State private var loadingImageData: Bool = false
    
    var body: some View {
        ZStack {
            List {
                
                Section {
                    ZStack {
                        VStack {
                            if let libraryImage = viewModel.libraryImage {
                                Image(uiImage: libraryImage)
                                    .resizable()
                                    .frame(width: 100, height: 100)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                
                            } else {
                                RoundedRectangle(cornerRadius: 12)
                                    .foregroundStyle(Color.gray)
                                    .frame(width: 100, height: 100)
                            }
                            PhotosPicker(selection: $selectedPhotos,
                                         maxSelectionCount: 1,
                                         matching: .images,
                                         label: {
                                Text("Select Photo")
                            })
                        }
                        .onChange(of: selectedPhotos) { _ in
                            convertDataToImage()
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
                .listRowBackground(Color.clear)

                
                Section {
                    VStack(alignment: .leading) {
                        Text("Display Name")
                        TextField("enter display name...", text: $viewModel.displayName)
                            .tint(Color(.darkColour))
                            .autocorrectionDisabled()
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
                            Button(position.title) { viewModel.playerPositions.append(position)}
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
    
    func convertDataToImage() {
        // reset the images array before adding more/new photos
        viewModel.libraryImage = nil
        loadingImageData = true
        
        if !selectedPhotos.isEmpty {
            for eachItem in selectedPhotos {
                Task {
                    if let imageData = try? await eachItem.loadTransferable(type: Data.self) {
                        if let image = UIImage(data: imageData) {
                            viewModel.libraryImage = image
                        }
                    }
                }
            }
        }
        
        // uncheck the images in the system photo picker
        selectedPhotos.removeAll()
    }
}

struct CreatePlayerView_Previews: PreviewProvider {
    private class PreviewPlayerLoader: PlayerLoader {
        func loadAllPlayers(for teamID: String, in clubID: String) async throws -> [RemotePlayerModel] { return [] }
        func loadPlayer(with uid: String, from clubID: String) async throws -> RemotePlayerModel { return .example }
        func loadAllPlayers(for clubID: String) async throws -> [RemotePlayerModel] { return [] }
        func uploadNewPlayer(_ model: RemotePlayerModel, to teams: [String]) async throws {}
    }
    private class PreviewTeamLoader: TeamLoader {
        func loadAllTeams(for clubID: String) async throws -> [RemoteTeamModel] { return [] }
        func loadTeam(with teamID: String, from clubID: String) async throws -> RemoteTeamModel {
            return .example
        }
    }
    private class PreviewService: PlayerCreationService {
        func createNewPlayer(with data: NewPlayerData) async -> Result<NewPlayerData, RemotePlayerCreationService.Error> { return .failure(.failed)}
    }
    static var previews: some View {
        CreatePlayerView(viewModel: CreatePlayerViewModel(clubModel: .example, loader: PreviewPlayerLoader(), teamLoader: PreviewTeamLoader(), creationService: PreviewService()))
    }
}
