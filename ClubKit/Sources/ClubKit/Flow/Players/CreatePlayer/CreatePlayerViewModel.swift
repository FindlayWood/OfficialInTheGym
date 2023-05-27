//
//  File.swift
//  
//
//  Created by Findlay-Personal on 22/05/2023.
//

import Foundation

class CreatePlayerViewModel: ObservableObject {
    
    // MARK: - Dependencies
    var clubModel: RemoteClubModel
    var loader: PlayerLoader
    var teamLoader: TeamLoader
    // MARK: - Loading Variables
    @Published var isLoadingTeams: Bool = false
    @Published var isUploading: Bool = false
    @Published var uploaded: Bool = false
    @Published var errorUploading: Bool = false
    // MARK: - New Model Variables
    @Published var displayName: String = ""
    @Published var playerPositions: [Positions] = []
    @Published var teams: [RemoteTeamModel] = []
    @Published var selectedTeams: [RemoteTeamModel] = []
    var selectedSport: Sport
    
    init(clubModel: RemoteClubModel, loader: PlayerLoader, teamLoader: TeamLoader) {
        self.clubModel = clubModel
        self.loader = loader
        self.teamLoader = teamLoader
        self.selectedSport = clubModel.sport
    }
    
    @MainActor
    func loadTeams() {
        isLoadingTeams = true
        Task {
            do {
                teams = try await teamLoader.loadAllTeams(for: clubModel.id)
                isLoadingTeams = false
            } catch {
                print(String(describing: error))
                isLoadingTeams = false
            }
        }
    }
    
    @MainActor
    func toggleSelectedTeam(_ model: RemoteTeamModel) {
        if let index = selectedTeams.firstIndex(where: { $0.id == model.id }) {
            selectedTeams.remove(at: index)
        } else {
            selectedTeams.append(model)
        }
    }
    
    @MainActor
    func create() async {
        isUploading = true
        let newModel = RemotePlayerModel(id: UUID().uuidString, clubID: clubModel.id, displayName: displayName, positions: playerPositions)
        do {
            try await loader.uploadNewPlayer(newModel, to: selectedTeams.map { $0.id })
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.displayName = ""
                self.playerPositions.removeAll()
                self.selectedTeams.removeAll()
                self.isUploading = false
                self.uploaded = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    self.uploaded = false
                }
            }
        } catch {
            print(String(describing: error))
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.isUploading = false
                self.errorUploading = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    self.errorUploading = false
                }
            }
        }
    }
    
    var buttonDisabled: Bool {
        displayName.isEmpty || playerPositions.isEmpty
    }
}
