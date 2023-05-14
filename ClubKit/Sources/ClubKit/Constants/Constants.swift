//
//  File.swift
//  
//
//  Created by Findlay-Personal on 14/05/2023.
//

import Foundation

enum Constants {
    static func clubDataPath(_ userID: String) -> String {
        "Users/\(userID)/clubData"
    }
    static func clubPath(_ clubID: String) -> String {
        "Clubs/\(clubID)"
    }
}
