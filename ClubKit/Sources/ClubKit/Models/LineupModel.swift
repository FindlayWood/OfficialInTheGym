//
//  File.swift
//  
//
//  Created by Findlay Wood on 08/11/2023.
//

import Foundation

protocol LineupModel {
    
}

struct RemoteLineupModel: Codable {
    let id: String
    let createdBy: String
    let createdDate: Date
    let name: String
}


struct RemoteLineupPlayerModel: Codable {
    let playerID: String
    let position: Int
}

struct UploadLineupModel: Codable {
    let clubID: String
    let teamID: String
    let lineupID: String
    let selectedPlayers: [RemoteLineupPlayerModel]
    let name: String
    
}
