//
//  File.swift
//  
//
//  Created by Findlay Wood on 08/11/2023.
//

import Foundation

protocol LineupLoader {
    func loadAllLineups(for teamID: String, in clubID: String) async throws -> [RemoteLineupModel]
//    func loadLineup(with lineupID: String, for teamID: String, in clubID: String) async throws -> RemoteLineupModel
    func loadAllLineupPlayerModels(with lineupID: String, for teamID: String, in clubID: String) async throws -> [RemoteLineupPlayerModel]
}

class RemoteLineupLoader: LineupLoader {
    
    var networkService: NetworkService
    
    init(networkService: NetworkService) {
        self.networkService = networkService
    }
    
    func loadAllLineups(for teamID: String, in clubID: String) async throws -> [RemoteLineupModel] {
        return try await networkService.readAll(at: Constants.lineupsPath(for: teamID, in: clubID))
    }
    
    func loadLineup(with lineupID: String, for teamID: String, in clubID: String) async throws -> RemoteLineupModel {
        return try await networkService.read(at: Constants.lineupPath(for: teamID, in: clubID, with: lineupID))
    }
    
    func loadAllLineupPlayerModels(with lineupID: String, for teamID: String, in clubID: String) async throws -> [RemoteLineupPlayerModel] {
        return try await networkService.readAll(at: Constants.lineupPlayersPath(for: teamID, in: clubID, with: lineupID))
    }
}
