//
//  FirebaseFunctionsConstants.swift
//  
//
//  Created by Findlay Wood on 17/02/2024.
//

import Foundation

enum FirebaseFunctionsConstants {
    
    static let deleteClub: String = "deleteClub"
    static let createTeam: String = "createTeam"
    static let updatePlayerDetail: String = "updatePlayerDetail"
}

enum FunctionKeys {
    
    enum DeleteClubFunction {
        static let id: String = "id"
        static let linkedUserUIDs: String = "linkedUserUIDs"
    }
    
    enum CreateTeamFunction {
        static let clubID: String = "clubID"
        static let teamID: String = "teamID"
        static let teamName: String = "teamName"
        static let isPrivate: String = "isPrivate"
        static let sport: String = "sport"
        static let players: String = "players"
    }
    
    enum UpdatePlayerDetailFunction {
        static let playerID: String = "playerID"
        static let clubID: String = "clubID"
        static let displayName: String = "displayName"
        static let positions: String = "positions"
        static let imageData: String = "imageData"
    }
}
