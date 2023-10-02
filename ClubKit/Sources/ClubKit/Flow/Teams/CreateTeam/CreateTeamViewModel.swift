//
//  File.swift
//  
//
//  Created by Findlay Wood on 01/10/2023.
//

import Foundation

class CreateTeamViewModel: ObservableObject {
    
    var playerLoader: PlayerLoader
    var teamCreationService: TeamCreationService
    var clubModel: RemoteClubModel
    
    // MARK: - Loading Variables
    @Published var isLoadingPlayers: Bool = false
    @Published var isLoadingTeams: Bool = false
    @Published var isUploading: Bool = false
    @Published var uploaded: Bool = false
    @Published var errorUploading: Bool = false
    @Published var errorLoading: Error?
    @Published var players: [RemotePlayerModel] = []
    // MARK: - New Model Variables
    @Published var displayName: String = ""
    var selectedSport: Sport
    
    init(playerLoader: PlayerLoader, teamCreationService: TeamCreationService, clubModel: RemoteClubModel) {
        self.playerLoader = playerLoader
        self.teamCreationService = teamCreationService
        self.clubModel = clubModel
        self.selectedSport = clubModel.sport
    }
    
    
    @MainActor
    func create() async {
        isUploading = true
        let newTeamData = NewTeamData(displayName: displayName, clubID: clubModel.id, isPrivate: false, sport: selectedSport)
        let result = await teamCreationService.createNewTeam(with: newTeamData)
        switch result {
        case .success:
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.displayName = ""
                self.isUploading = false
                self.uploaded = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    self.uploaded = false
                }
            }
        case .failure(let failure):
            print(String(describing: failure))
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.isUploading = false
                self.errorUploading = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    self.errorUploading = false
                }
            }
        }
    }
    
    @MainActor
    func loadPlayers() async {
        isLoadingPlayers = true
        do {
            players = try await playerLoader.loadAllPlayers(for: clubModel.id)
            isLoadingPlayers = false
        } catch {
            errorLoading = error
            print(String(describing: error))
            isLoadingPlayers = false
        }
    }
    
    var buttonDisabled: Bool {
        displayName.isEmpty
    }
}
