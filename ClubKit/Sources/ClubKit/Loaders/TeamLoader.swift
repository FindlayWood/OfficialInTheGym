//
//  File.swift
//  
//
//  Created by Findlay-Personal on 22/05/2023.
//

import Foundation

protocol TeamLoader {
    func loadAllTeams(for clubID: String) async throws -> [RemoteTeamModel]
}

class RemoteTeamLoader: TeamLoader {
    
    var networkService: NetworkService
    
    init(networkService: NetworkService) {
        self.networkService = networkService
    }
    
    func loadAllTeams(for clubID: String) async throws -> [RemoteTeamModel] {
        return try await networkService.readAll(at: Constants.teamsPath(clubID))
    }
}
