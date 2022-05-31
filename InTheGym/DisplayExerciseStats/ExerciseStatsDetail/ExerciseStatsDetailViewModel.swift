//
//  ExerciseStatsDetailViewModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 15/02/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
import Combine

struct ExerciseStatsDetailViewModel {
    
    // MARK: - Publisher
    var viewMax = PassthroughSubject<Void,Never>()
    
    // MARK: - Properties
    var statsModel: ExerciseStatsModel!
}
