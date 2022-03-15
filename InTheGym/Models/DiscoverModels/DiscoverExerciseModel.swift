//
//  DiscoverExerciseModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 15/03/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation

// MARK: - Discover Exercise Model
struct DiscoverExerciseModel: Hashable {
    var exerciseName: String
    
    private let identifier = UUID()
}
