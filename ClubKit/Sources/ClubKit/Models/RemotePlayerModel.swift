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
    var displayName: String
    var positions: [Positions]
    var linkedAccountUID: String?
}

extension RemotePlayerModel {
    static let example = RemotePlayerModel(id: UUID().uuidString, clubID: "example", displayName: "Example Player", positions: [.pointGuard])
}
