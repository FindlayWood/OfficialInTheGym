//
//  File.swift
//  
//
//  Created by Findlay-Personal on 11/05/2023.
//

import Foundation

struct RemoteClubData: Codable {
    var id: String
    var clubID: String
    var role: ClubRole
    var dateJoined: Date
}
