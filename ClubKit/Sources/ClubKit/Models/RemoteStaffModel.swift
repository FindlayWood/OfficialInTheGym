//
//  File.swift
//  
//
//  Created by Findlay-Personal on 10/05/2023.
//

import Foundation

struct RemoteStaffModel: Codable {
    var id: String
    var displayName: String
    var addedDate: Date
    var role: StaffRoles
    var userProfileID: String?
    var userProfileUsername: String?
}
