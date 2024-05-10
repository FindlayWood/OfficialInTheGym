//
//  File.swift
//  
//
//  Created by Findlay-Personal on 04/02/2024.
//

import Foundation

protocol ClubCreationService {
    func createNewClub(with data: NewClubData) async -> Result<NewClubData,RemoteCreationService.Error>
}

protocol Client {
    func callFunction(named: String, with data: Any) async throws
}

struct FirebaseClient: Client {
    
    var service: NetworkService
    
    func callFunction(named: String, with data: Any) async throws {
        try await service.callFunction(named: named, with: data)
    }
}

struct NewClubData {
    let id: String = UUID().uuidString
    let displayName: String
    let tagline: String
    let sport: Sport
    let isPrivate: Bool
    let currentUserRole: ClubRole
    let positions: [Positions]
    let imageData: String?
}

struct RemoteCreationService: ClubCreationService {
    
    var client: Client
    
    public enum Error: Swift.Error {
        case failed
    }
    
    func createNewClub(with data: NewClubData) async -> Result<NewClubData,Error> {
        var functionData: [String: Any] = [
            "id": data.id,
            "clubName": data.displayName,
            "sport": data.sport.rawValue,
            "tagline": data.tagline,
            "isPrivate": data.isPrivate,
            "currentUserRole": data.currentUserRole.rawValue,
            "positions": data.positions.map { $0.rawValue }
        ]
        if let imageData = data.imageData {
            functionData["imageData"] = imageData
        }
        do {
            try await client.callFunction(named: "createClub", with: functionData)
            return .success(data)
        } catch {
            return .failure(.failed)
        }
    }
}

struct PreviewClubCreationService: ClubCreationService {
    func createNewClub(with data: NewClubData) async -> Result<NewClubData, RemoteCreationService.Error> {
        .failure(.failed)
    }
}
