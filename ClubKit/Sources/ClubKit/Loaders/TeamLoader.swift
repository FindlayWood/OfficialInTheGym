//
//  File.swift
//  
//
//  Created by Findlay-Personal on 22/05/2023.
//

import Foundation

protocol TeamLoader {
    func loadAllTeams(for clubID: String) async throws -> [RemoteTeamModel]
    func loadTeam(with teamID: String, from clubID: String) async throws -> RemoteTeamModel
}

class RemoteTeamLoader: TeamLoader {
    
    var networkService: NetworkService
    
    init(networkService: NetworkService) {
        self.networkService = networkService
    }
    
    func loadAllTeams(for clubID: String) async throws -> [RemoteTeamModel] {
        return try await networkService.readAll(at: Constants.teamsPath(clubID))
    }
    func loadTeam(with teamID: String, from clubID: String) async throws -> RemoteTeamModel {
        return try await networkService.read(at: Constants.teamPath(clubID, teamID))
    }
}

struct PreviewTeamLoader: TeamLoader {
    func loadAllTeams(for clubID: String) async throws -> [RemoteTeamModel] {
        return []
    }
    func loadTeam(with teamID: String, from clubID: String) async throws -> RemoteTeamModel {
        return .example
    }
}
