//
//  File.swift
//  
//
//  Created by Findlay-Personal on 24/05/2023.
//

import Foundation

protocol PlayerLoader {
    func loadAllPlayers(for clubID: String) async throws -> [RemotePlayerModel]
    func loadPlayer(with uid: String, from clubID: String) async throws -> RemotePlayerModel
    func loadAllPlayers(for teamID: String, in clubID: String) async throws -> [RemotePlayerModel]
    func uploadNewPlayer(_ model: RemotePlayerModel, to teams: [String]) async throws
}

class RemotePlayerLoader: PlayerLoader {
    
    var networkService: NetworkService
    
    init(networkService: NetworkService) {
        self.networkService = networkService
    }
    
    func loadPlayer(with uid: String, from clubID: String) async throws -> RemotePlayerModel {
        return try await networkService.read(at: Constants.playerPath(clubID, uid))
    }
    
    func loadAllPlayers(for clubID: String) async throws -> [RemotePlayerModel] {
        return try await networkService.readAll(at: Constants.playersPath(for: clubID))
    }
    
    func loadAllPlayers(for teamID: String, in clubID: String) async throws -> [RemotePlayerModel] {
        let playerID: [TeamPlayerModel] = try await networkService.readAll(at: Constants.teamPlayersPath(for: teamID, in: clubID))
        var playerModels: [RemotePlayerModel] = []
        for model in playerID {
            let player: RemotePlayerModel = try await loadPlayer(with: model.playerUID, from: clubID)
            playerModels.append(player)
        }
        return playerModels
    }
    
    func uploadNewPlayer(_ model: RemotePlayerModel, to teams: [String]) async throws {
        var data: [String: Codable] = [:]
        for team in teams {
            let path = Constants.teamPlayerPath(model.clubID, team, model.id)
            let dataPoint = PlayerIDUpload(playerUID: model.id, clubID: model.clubID)
            data[path] = dataPoint
        }
        data[Constants.playerPath(model.clubID, model.id)] = model
        try await networkService.write(dataPoints: data)
    }
}

struct PlayerIDUpload: Codable {
    var playerUID: String
    var clubID: String
}

struct TeamPlayerModel: Codable {
    let playerUID: String
}
