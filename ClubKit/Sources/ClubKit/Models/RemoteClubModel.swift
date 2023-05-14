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
    var createdDate: String
    var sport: Sport
    var verified: Bool
}
