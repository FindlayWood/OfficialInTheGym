//
//  File.swift
//  
//
//  Created by Findlay-Personal on 22/05/2023.
//

import Foundation

struct RemotePlayerModel: Codable {
    var id: String
    var displayName: String
    var linkedAccountUID: String?
}

extension RemotePlayerModel {
    static let example = RemotePlayerModel(id: UUID().uuidString, displayName: "Example Player")
}
