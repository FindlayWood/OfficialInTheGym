//
//  File.swift
//  
//
//  Created by Findlay-Personal on 11/05/2023.
//

import Foundation

protocol ClubLoader {
    func loadClub(with id: String) async throws -> RemoteClubModel
    func loadAllClubs(with clubData: [RemoteClubData]) async throws -> [RemoteClubModel]
    func loadClubData() async throws -> [RemoteClubData]
}

class RemoteClubLoader: ClubLoader {
    
    var networkService: NetworkService
    var userService: CurrentUserService
    
    init(networkService: NetworkService, userService: CurrentUserService) {
        self.networkService = networkService
        self.userService = userService
    }
    
    func loadClub(with id: String) async throws -> RemoteClubModel {
        return try await networkService.read(at: Constants.clubPath(id))
    }
    func loadAllClubs(with clubData: [RemoteClubData]) async throws -> [RemoteClubModel] {
        var clubs: [RemoteClubModel] = []
        for datum in clubData {
            let club: RemoteClubModel = try await loadClub(with: datum.clubID)
            clubs.append(club)
        }
        return clubs
    }
    func loadClubData() async throws -> [RemoteClubData] {
        return try await networkService.readAll(at: Constants.clubDataPath(userService.currentUserUID))
    }
}
