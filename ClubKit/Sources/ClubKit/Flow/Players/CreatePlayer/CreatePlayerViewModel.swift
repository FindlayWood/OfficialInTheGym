//
//  File.swift
//  
//
//  Created by Findlay-Personal on 22/05/2023.
//

import Foundation

class CreatePlayerViewModel: ObservableObject {
    
    var clubModel: RemoteClubModel
    var loader: PlayerLoader
    var teamLoader: TeamLoader
    @Published var isLoadingTeams: Bool = false
    @Published var isUplaoding: Bool = false
    @Published var displayName: String = ""
    @Published var selectedSport: Sport {
        willSet {
            if newValue != selectedSport {
                playerPositions.removeAll()
            }
        }
    }
    @Published var playerPositions: [Positions] = []
    @Published var teams: [RemoteTeamModel] = []
    @Published var selectedTeams: [RemoteTeamModel] = []
    
    init(clubModel: RemoteClubModel, loader: PlayerLoader, teamLoader: TeamLoader) {
        self.clubModel = clubModel
        self.selectedSport = clubModel.sport
        self.loader = loader
        self.teamLoader = teamLoader
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
        isUplaoding = true
        let newModel = RemotePlayerModel(id: UUID().uuidString, clubID: clubModel.id, displayName: displayName, positions: playerPositions)
        do {
            try await loader.uploadNewPlayer(newModel)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.displayName = ""
                self.playerPositions.removeAll()
                self.isUplaoding = false
            }
        } catch {
            print(String(describing: error))
            isUplaoding = false
        }
    }
    
    var buttonDisabled: Bool {
        displayName.isEmpty || playerPositions.isEmpty
    }
}
