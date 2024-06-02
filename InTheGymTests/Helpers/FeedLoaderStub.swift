//
//  FeedLoaderStub.swift
//  InTheGymTests
//
//  Created by Findlay Wood on 02/06/2024.
//  Copyright © 2024 FindlayWood. All rights reserved.
//

import ITGWorkoutKit

class FeedLoaderStub: WorkoutLoader {
    private let result: WorkoutLoader.Result

    init(result: WorkoutLoader.Result) {
        self.result = result
    }

    func load(completion: @escaping (WorkoutLoader.Result) -> Void) {
        completion(result)
    }
}
