//
//  TeamCreationService.swift
//
//
//  Created by Findlay Wood on 17/02/2024.
//

import Foundation

protocol TeamCreationService {
    func createNewTeam(with data: NewTeamData) async -> Result<NewTeamData,RemoteTeamCreationService.Error>
}

struct NewTeamData {
    let displayName: String
    let clubID: String
    let teamID: String = UUID().uuidString
    let isPrivate: Bool
    let sport: Sport
    let players: [String]
}

struct RemoteTeamCreationService: TeamCreationService {
    
    var client: Client
    
    public enum Error: Swift.Error {
        case failed
    }
    
    func createNewTeam(with data: NewTeamData) async -> Result<NewTeamData,Error> {
        let functionData: [String: Any] = [
            FunctionKeys.CreateTeamFunction.clubID: data.clubID,
            FunctionKeys.CreateTeamFunction.teamID: data.teamID,
            FunctionKeys.CreateTeamFunction.teamName: data.displayName,
            FunctionKeys.CreateTeamFunction.isPrivate: data.isPrivate,
            FunctionKeys.CreateTeamFunction.sport: data.sport.rawValue,
            FunctionKeys.CreateTeamFunction.players: data.players
        ]
        do {
            try await client.callFunction(named: FirebaseFunctionsConstants.createTeam, with: functionData)
            return .success(data)
        } catch {
            return .failure(.failed)
        }
    }
}
