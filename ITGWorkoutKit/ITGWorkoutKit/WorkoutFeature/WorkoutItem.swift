//
//  WorkoutItem.swift
//  ITGWorkoutKit
//
//  Created by Findlay Wood on 03/03/2024.
//

import Foundation

public struct WorkoutItem: Equatable {
    public let id: String
    public let title: String
    
    public init(id: String, title: String) {
        self.id = id
        self.title = title
    }
}
