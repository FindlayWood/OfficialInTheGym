//
//  File.swift
//  
//
//  Created by Findlay-Personal on 29/05/2023.
//

import Foundation

class PlayerSelectionViewModel: ObservableObject {
    
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
    
    var clubModel: RemoteClubModel
    var playerLoader: PlayerLoader
    
    init(clubModel: RemoteClubModel, playerLoader: PlayerLoader) {
        self.clubModel = clubModel
        self.playerLoader = playerLoader
    }
}
