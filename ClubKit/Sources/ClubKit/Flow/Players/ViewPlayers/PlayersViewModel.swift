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
    @Published var selectedPlayers: [RemotePlayerModel] = []
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
    let selectable: Bool
    let imageCache: ImageCache
    
    var selectedPlayer: ((RemotePlayerModel) -> ())?
    var selectedPlayersConfirmed: (([RemotePlayerModel]) -> ())?
    
    init(clubModel: RemoteClubModel, playerLoader: PlayerLoader, selectable: Bool = false, imageCache: ImageCache) {
        self.clubModel = clubModel
        self.playerLoader = playerLoader
        self.selectable = selectable
        self.imageCache = imageCache
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
    
    func toggleSelection(of model: RemotePlayerModel) {
        if selectedPlayers.contains(where: { $0 == model }) {
            selectedPlayers.removeAll(where: { $0 == model })
        } else {
            selectedPlayers.append(model)
        }
    }
    
    func checkSelection(of model: RemotePlayerModel) -> Bool {
        selectedPlayers.contains(model)
    }
    
    func confirmSelectionAction() {
        selectedPlayersConfirmed?(selectedPlayers)
    }
    
    func tappedOn(_ model: RemotePlayerModel) {
        selectable ? toggleSelection(of: model) : selectedPlayer?(model)
    }
}
