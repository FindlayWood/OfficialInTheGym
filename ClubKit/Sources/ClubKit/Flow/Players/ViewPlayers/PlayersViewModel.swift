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
    
    var clubModel: RemoteClubModel
    var playerLoader: PlayerLoader
    
    init(clubModel: RemoteClubModel, playerLoader: PlayerLoader) {
        self.clubModel = clubModel
        self.playerLoader = playerLoader
    }
    
    @MainActor
    func load() async {
        isLoading = true
        do {
            players = try await playerLoader.loadAllPlayers(for: clubModel.id)
            isLoading = false
        } catch {
            errorLoading = error
            print(String(describing: error))
            isLoading = false
        }
    }
}
