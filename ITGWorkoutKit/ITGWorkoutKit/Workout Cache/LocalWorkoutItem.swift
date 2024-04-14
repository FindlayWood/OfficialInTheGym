//
//  LocalWorkoutItem.swift
//  ITGWorkoutKit
//
//  Created by Findlay Wood on 11/04/2024.
//

import Foundation

public struct LocalWorkoutItem: Equatable, Codable {
    public let id: UUID
    public let description: String?
    public let location: String?
    public let image: URL?
    
    public init(id: UUID, description: String?, location: String?, image: URL?) {
        self.id = id
        self.description = description
        self.location = location
        self.image = image
    }
}
