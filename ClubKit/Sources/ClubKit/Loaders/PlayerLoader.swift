//
//  File.swift
//  
//
//  Created by Findlay-Personal on 24/05/2023.
//

import Foundation

protocol PlayerLoader {
    func loadAllPlayers(for clubID: String) async throws -> [RemotePlayerModel]
    func uploadNewPlayer(_ model: RemotePlayerModel) async throws
}

class RemotePlayerLoader: PlayerLoader {
    
    var networkService: NetworkService
    
    init(networkService: NetworkService) {
        self.networkService = networkService
    }
    
    func loadAllPlayers(for clubID: String) async throws -> [RemotePlayerModel] {
        return try await networkService.readAll(at: Constants.playersPath(for: clubID))
    }
    
    func uploadNewPlayer(_ model: RemotePlayerModel) async throws {
        try await networkService.write(data: model, at: Constants.playerPath(model.clubID, model.id))
    }
}
