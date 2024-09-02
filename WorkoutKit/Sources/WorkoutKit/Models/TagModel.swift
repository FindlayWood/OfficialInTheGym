//
//  File.swift
//  
//
//  Created by Findlay-Personal on 29/04/2023.
//

import Foundation

struct TagModel: Codable, Identifiable {
    var tag: String
    var id: String = UUID().uuidString
}
