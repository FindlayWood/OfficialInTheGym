//
//  File.swift
//  
//
//  Created by Findlay-Personal on 24/05/2023.
//

import Foundation

class PlayersViewModel: ObservableObject {
    
    @Published var errorLoading: Error?
    @Published var players: [RemotePlayerModel] = []
    @Published var isLoading: Bool = false
    
    @Published var searchText: String = ""
    
    var searchedPlayers: [RemotePlayerModel] {
        if searchText.isEmpty {
            return players
        } else {
            return players.filter { $0.displayName.lowercased().contains(searchText.lowercased())
                || $0.positions.map { $0.rawValue.lowercased().contains(searchText.lowercased()) }.contains(true)
            }
        }
    }
    
    var excludedPlayers: [RemotePlayerModel] = []
    
    var clubModel: RemoteClubModel
    var playerLoader: PlayerLoader
    
    var selectedPlayer: ((RemotePlayerModel) -> ())?
    
    init(clubModel: RemoteClubModel, playerLoader: PlayerLoader) {
        self.clubModel = clubModel
        self.playerLoader = playerLoader
    }
    
    func loadFromClub() {
        Task { @MainActor in
            isLoading = true
            do {
                players = try await playerLoader.loadAllPlayers(for: clubModel.id).filter(checkForExclusion)
                isLoading = false
            } catch {
                errorLoading = error
                print(String(describing: error))
                isLoading = false
            }
        }
    }
    
    func loadFromTeam(with teamID: String) {
        Task { @MainActor in
            isLoading = true
            do {
                players = try await playerLoader.loadAllPlayers(for: teamID, in: clubModel.id).filter(checkForExclusion)
                isLoading = false
            } catch {
                errorLoading = error
                print(String(describing: error))
                isLoading = false
            }
        }
    }
    
    func checkForExclusion(_ model: RemotePlayerModel) -> Bool {
        !(excludedPlayers.contains(where: { $0.id == model.id }))
    }
}
