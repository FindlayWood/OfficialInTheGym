//
//  File.swift
//  
//
//  Created by Findlay-Personal on 24/05/2023.
//

import Foundation

protocol PlayerLoader {
    func loadAllPlayers(for clubID: String) async throws -> [RemotePlayerModel]
    func uploadNewPlayer(_ model: RemotePlayerModel, to teams: [String]) async throws
}

class RemotePlayerLoader: PlayerLoader {
    
    var networkService: NetworkService
    
    init(networkService: NetworkService) {
        self.networkService = networkService
    }
    
    func loadAllPlayers(for clubID: String) async throws -> [RemotePlayerModel] {
        return try await networkService.readAll(at: Constants.playersPath(for: clubID))
    }
    
    func uploadNewPlayer(_ model: RemotePlayerModel, to teams: [String]) async throws {
        var data: [String: Codable] = [:]
        for team in teams {
            let path = Constants.teamPlayerPath(model.clubID, team, model.id)
            let dataPoint = PlayerIDUpload(playerUID: model.id)
            data[path] = dataPoint
        }
        data[Constants.playerPath(model.clubID, model.id)] = model
        try await networkService.write(dataPoints: data)
    }
}

struct PlayerIDUpload: Codable {
    var playerUID: String
}
