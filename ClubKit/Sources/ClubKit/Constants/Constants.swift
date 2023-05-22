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
    static func playerPath(in clubID: String, _ playerID: String) -> String {
        "Clubs/\(clubID)/Players/\(playerID)"
    }
}
