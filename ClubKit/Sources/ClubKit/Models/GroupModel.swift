//
//  File.swift
//  
//
//  Created by Findlay Wood on 19/11/2023.
//

import Foundation

struct RemoteGroupModel: Codable, Identifiable {
    let id: String
    let clubID: String
    let name: String
    let createdBy: String
    let createdDate: Date
    let members: [String]
}
extension RemoteGroupModel {
    static let example = RemoteGroupModel(id: UUID().uuidString, clubID: UUID().uuidString, name: "Example", createdBy: "creator", createdDate: .now, members: [])
}
