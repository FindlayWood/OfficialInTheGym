//
//  File.swift
//  
//
//  Created by Findlay-Personal on 10/05/2023.
//

import Foundation

protocol ClubManager {
    var clubs: [RemoteClubModel] { get }
    var clubsPublished: Published<[RemoteClubModel]> { get }
    var clubsPublisher: Published<[RemoteClubModel]>.Publisher { get }
    func loadClubData() async throws -> [RemoteClubData]
    func loadClubs() async throws
    func loadTeams(for club: RemoteClubModel) async throws -> [RemoteTeamModel]
    func createdNewClub(_ model: RemoteClubModel)
}

class RemoteClubManager: ClubManager {
    
    var clubLoader: ClubLoader
    
    @Published private(set) var clubs: [RemoteClubModel] = []
    var clubsPublished: Published<[RemoteClubModel]> { _clubs }
    var clubsPublisher: Published<[RemoteClubModel]>.Publisher { $clubs }
    
    init(clubLoader: ClubLoader) {
        self.clubLoader = clubLoader
    }
    
    
    func loadClubData() async throws -> [RemoteClubData] {
        return try await clubLoader.loadClubData()
    }
    
    func loadClubs() async throws {
        let clubData = try await loadClubData()
        clubs = try await clubLoader.loadAllClubs(with: clubData)
    }
    
    func loadTeams(for club: RemoteClubModel) async throws -> [RemoteTeamModel] {
        return []
    }
    
    func createdNewClub(_ model: RemoteClubModel) {
        clubs.append(model)
    }
}

class PreviewClubManager: ClubManager {
    @Published var clubs: [RemoteClubModel] = []
    var clubsPublished: Published<[RemoteClubModel]> { _clubs }
    var clubsPublisher: Published<[RemoteClubModel]>.Publisher { $clubs }
    
    func loadClubData() async throws -> [RemoteClubData] {
        return []
    }
    
    func loadClubs() async throws {
        
    }
    
    func loadTeams(for club: RemoteClubModel) async throws -> [RemoteTeamModel] {
        return []
    }
    func createdNewClub(_ model: RemoteClubModel) {
        
    }
}
