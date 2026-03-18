//
//  File.swift
//  
//
//  Created by Findlay-Personal on 22/05/2023.
//

import Foundation

struct RemotePlayerModel: Codable, Identifiable, Equatable {
    var id: String
    var clubID: String
    let createdDate: Date
    var displayName: String
    var positions: [Positions]
    var teams: [String]
    var groups: [String]
    var linkedAccountUID: String?
}

extension RemotePlayerModel {
    static let example = RemotePlayerModel(id: UUID().uuidString, clubID: "example", createdDate: .now, displayName: "Example Player", positions: [.pointGuard], teams: [], groups: [])
}
