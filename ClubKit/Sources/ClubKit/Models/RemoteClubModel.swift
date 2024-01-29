//
//  File.swift
//  
//
//  Created by Findlay-Personal on 10/05/2023.
//

import Foundation

struct RemoteClubModel: Codable, Identifiable, Equatable {
    var id: String
    var clubName: String
    var tagline: String
    var createdBy: String
    var createdDate: Date
    var sport: Sport
    var verified: Bool
    var teamCount: Int
    var athleteCount: Int
    let linkedUserUIDs: [String]
}
extension RemoteClubModel {
    static let example = RemoteClubModel(id: UUID().uuidString, clubName: "Example", tagline: "this is an example", createdBy: "", createdDate: .now, sport: .rugby, verified: true, teamCount: 3, athleteCount: 29, linkedUserUIDs: [])
}
