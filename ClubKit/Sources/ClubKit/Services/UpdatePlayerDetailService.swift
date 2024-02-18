//
//  UpdatePlayerDetailService.swift
//
//
//  Created by Findlay Wood on 18/02/2024.
//

import Foundation

protocol UpdatePlayerDetailService {
    func updatePlayer(with data: UpdatePlayerData) async -> Result<UpdatePlayerData,RemoteUpdatePlayerDetailService.Error>
}

struct UpdatePlayerData {
    let playerID: String
    let displayName: String
    let clubID: String
    let positions: [String]
    let imageData: String?
}

struct RemoteUpdatePlayerDetailService: UpdatePlayerDetailService {
    
    var client: Client
    
    public enum Error: Swift.Error {
        case failed
    }
    
    func updatePlayer(with data: UpdatePlayerData) async -> Result<UpdatePlayerData,Error> {
        var functionData: [String: Any] = [
            FunctionKeys.UpdatePlayerDetailFunction.clubID: data.clubID,
            FunctionKeys.UpdatePlayerDetailFunction.playerID: data.playerID,
            FunctionKeys.UpdatePlayerDetailFunction.displayName: data.displayName,
            FunctionKeys.UpdatePlayerDetailFunction.positions: data.positions,
        ]
        if let imageData = data.imageData {
            functionData[FunctionKeys.UpdatePlayerDetailFunction.imageData] = imageData
        }
        do {
            try await client.callFunction(named: FirebaseFunctionsConstants.updatePlayerDetail, with: functionData)
            return .success(data)
        } catch {
            return .failure(.failed)
        }
    }
}


struct PreviewUpdatePlayerDetailService: UpdatePlayerDetailService {
    func updatePlayer(with data: UpdatePlayerData) async -> Result<UpdatePlayerData, RemoteUpdatePlayerDetailService.Error> {
        return .failure(.failed)
    }
}
