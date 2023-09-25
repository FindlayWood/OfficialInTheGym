//
//  File.swift
//  
//
//  Created by Findlay-Personal on 14/05/2023.
//

import Foundation

enum Constants {
    static func clubDataPath(_ userID: String) -> String {
        "Users/\(userID)/ClubData"
    }
    static func clubPath(_ clubID: String) -> String {
        "Clubs/\(clubID)"
    }
    static func teamsPath(_ clubID: String) -> String {
        "Clubs/\(clubID)/Teams"
    }
    static func teamPath(_ clubID: String, _ teamID: String) -> String {
        "Clubs/\(clubID)/Teams/\(teamID)"
    }
    static func teamPlayerPath(_ clubID: String, _ teamID: String, _ playerID: String) -> String {
        "Clubs/\(clubID)/Teams/\(teamID)/Players/\(playerID)"
    }
    static func playerPath(_ clubID: String, _ playerID: String) -> String {
        "Clubs/\(clubID)/Players/\(playerID)"
    }
    static func playersPath(for clubID: String) -> String {
        "Clubs/\(clubID)/Players"
    }
}