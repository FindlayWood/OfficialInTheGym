//
//  File.swift
//  
//
//  Created by Findlay-Personal on 10/05/2023.
//

import Foundation

struct RemoteTeamModel: Codable, Identifiable {
    var id: String
    let clubID: String
    var teamName: String
    var createdBy: String
    var createdDate: Date
    var sport: Sport
    var athleteCount: Int
    var defaultLineup: String?
}

extension RemoteTeamModel {
    static let example = RemoteTeamModel(id: UUID().uuidString, clubID: "BRFC", teamName: "Bears", createdBy: "", createdDate: .now, sport: .rugby, athleteCount: 23)
}
