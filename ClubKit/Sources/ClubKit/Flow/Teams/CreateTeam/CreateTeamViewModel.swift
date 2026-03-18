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
    let imageCache: ImageCache
    
    // MARK: - Loading Variables
    @Published var isLoadingPlayers: Bool = false
    @Published var isLoadingTeams: Bool = false
    @Published var isUploading: Bool = false
    @Published var uploaded: Bool = false
    @Published var errorUploading: Bool = false
    @Published var errorLoading: Error?
    @Published var selectedPlayersList: [RemotePlayerModel] = []
    // MARK: - New Model Variables
    @Published var displayName: String = ""
    var selectedSport: Sport
    
    var selectedPlayers: (() -> ())?
    
    init(playerLoader: PlayerLoader, teamCreationService: TeamCreationService, clubModel: RemoteClubModel, imageCache: ImageCache) {
        self.playerLoader = playerLoader
        self.teamCreationService = teamCreationService
        self.clubModel = clubModel
        self.selectedSport = clubModel.sport
        self.imageCache = imageCache
    }
    
    
    @MainActor
    func create() async {
        isUploading = true
        let newTeamData = NewTeamData(displayName: displayName, clubID: clubModel.id, isPrivate: false, sport: selectedSport, players: selectedPlayersList.map { $0.id } )
        let result = await teamCreationService.createNewTeam(with: newTeamData)
        switch result {
        case .success:
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.displayName = ""
                self.selectedPlayersList.removeAll()
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
    
    func addPlayers(_ players: [RemotePlayerModel]) {
        selectedPlayersList = players
    }
    
    var buttonDisabled: Bool {
        displayName.isEmpty
    }
}
