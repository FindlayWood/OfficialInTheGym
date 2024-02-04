//
//  File.swift
//  
//
//  Created by Findlay Wood on 03/12/2023.
//

import Foundation

protocol PlayerCreationService {
    func createNewPlayer(with data: NewPlayerData) async -> Result<NewPlayerData,RemotePlayerCreationService.Error>
}

struct NewPlayerData {
    let playerID: String = UUID().uuidString
    let displayName: String
    let clubID: String
    let positions: [String]
    let selectedTeams: [String]
    let imageData: String?
}

struct RemotePlayerCreationService: PlayerCreationService {
    
    var client: Client
    
    public enum Error: Swift.Error {
        case failed
    }
    
    func createNewPlayer(with data: NewPlayerData) async -> Result<NewPlayerData,Error> {
        var functionData: [String: Any] = [
            "clubID": data.clubID,
            "playerID": data.playerID,
            "displayName": data.displayName,
            "positions": data.positions,
            "selectedTeams": data.selectedTeams
        ]
        if let imageData = data.imageData {
            functionData["imageData"] = imageData
        }
        do {
            try await client.callFunction(named: "createPlayer", with: functionData)
            return .success(data)
        } catch {
            return .failure(.failed)
        }
    }
}


struct PreviewPlayerCreationService: PlayerCreationService {
    func createNewPlayer(with data: NewPlayerData) async -> Result<NewPlayerData, RemotePlayerCreationService.Error> {
        return .failure(.failed)
    }
}
