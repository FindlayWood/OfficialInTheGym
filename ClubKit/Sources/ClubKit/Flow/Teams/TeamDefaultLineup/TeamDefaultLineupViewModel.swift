//
//  File.swift
//  
//
//  Created by Findlay-Personal on 07/06/2023.
//

import Foundation

class TeamDefaultLineupViewModel: ObservableObject {
    
    @Published var isEditing: Bool = false
    @Published var isLoading: Bool = false
    @Published var isUploading: Bool = false
    @Published var uploaded: Bool = false
    @Published var errorUploading: Bool = false
    
    @Published var lineupModels: [RemoteLineupPlayerModel] = []
    @Published var playerModels: [LineupPlayerModel] = []
    
    var team: RemoteTeamModel
    var lineupLoader: LineupLoader
    var playerLoader: PlayerLoader
    var lineupUploadService: UploadLineupService
    
    var addNewPlayer: ((Int) -> ())?
    
    init(team: RemoteTeamModel, lineupLoader: LineupLoader, playerLoader: PlayerLoader, lineupUploadService: UploadLineupService) {
        self.team = team
        self.lineupLoader = lineupLoader
        self.playerLoader = playerLoader
        self.lineupUploadService = lineupUploadService
    }
    
    func loadDefaultLineup() {
        guard let defaultLineup = team.defaultLineup else { return }
        isLoading = true
        Task { @MainActor in
            do {
                lineupModels = try await lineupLoader.loadAllLineupPlayerModels(with: defaultLineup, for: team.id, in: team.clubID)
                playerModels = try await loadAllPlayers(with: lineupModels)
                isLoading = false
            } catch {
                print(String(describing: error))
                isLoading = false
            }
        }
    }
    
    func loadAllPlayers(with lineupData: [RemoteLineupPlayerModel]) async throws -> [LineupPlayerModel] {
        var players: [LineupPlayerModel] = []
        for datum in lineupData {
            let player: RemotePlayerModel = try await playerLoader.loadPlayer(with: datum.playerID, from: team.clubID)
            players.append(.init(lineup: datum, playerModel: player))
        }
        return players
    }
    
    func checkNumber(_ number: Int) -> LineupPlayerModel? {
        if let model = playerModels.first(where: { $0.lineup.position == number }) {
            return model
        }
        return nil
    }
    
    func addPlayerToLineup(_ playerModel: RemotePlayerModel, at position: Int) {
        if playerModels.contains(where: { $0.playerModel.id == playerModel.id }) {
            print("no can do")
        } else {
            let lineupModel = RemoteLineupPlayerModel(playerID: playerModel.id, position: position)
            let newModel = LineupPlayerModel(lineup: lineupModel, playerModel: playerModel)
            playerModels.append(newModel)
        }
    }
    
    func removePlayer(_ index: Int) {
        if let playerIndex = playerModels.firstIndex(where: { $0.lineup.position == index }) {
            playerModels.remove(at: playerIndex)
        }
    }
    
    @MainActor
    func uploadAction() async {
        isUploading = true
        let lineupID = team.defaultLineup ?? UUID().uuidString
        let selectedPlayers = playerModels.map { $0.lineup }
        let newLineupModel = UploadLineupModel(clubID: team.clubID, teamID: team.id, lineupID: lineupID, selectedPlayers: selectedPlayers, name: "Default")
        let result = await lineupUploadService.uploadLineup(with: newLineupModel)
        switch result {
        case .success:
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.isUploading = false
                self.uploaded = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    self.uploaded = false
                }
            }
        case .failure(let failure):
            print(String(describing: failure))
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.errorUploading = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    self.errorUploading = false
                }
            }
        }
    }
}

struct LineupPlayerModel {
    let lineup: RemoteLineupPlayerModel
    let playerModel: RemotePlayerModel
}
