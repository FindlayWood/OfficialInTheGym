//
//  File.swift
//  
//
//  Created by Findlay-Personal on 10/05/2023.
//

import Foundation

struct RemoteStaffModel: Codable, Identifiable, Equatable {
    let id: String
    let clubID: String
    let displayName: String
    let createdBy: String
    let addedBy: String
    let createdDate: Date
    let role: StaffRoles
    let linkedAccountUID: String?
    let teams: [String]
}

extension RemoteStaffModel {
    static let example = RemoteStaffModel(id: UUID().uuidString, clubID: UUID().uuidString, displayName: "Example", createdBy: UUID().uuidString, addedBy: UUID().uuidString, createdDate: .now, role: .coach, linkedAccountUID: nil, teams: [])
}
