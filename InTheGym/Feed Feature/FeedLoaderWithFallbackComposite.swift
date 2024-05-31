//
//  FeedLoaderWithFallbackComposite.swift
//  InTheGym
//
//  Created by Findlay Wood on 31/05/2024.
//  Copyright © 2024 FindlayWood. All rights reserved.
//

import ITGWorkoutKit

public class FeedLoaderWithFallbackComposite: ITGWorkoutKit.WorkoutLoader {
    private let primary: ITGWorkoutKit.WorkoutLoader
    private let fallback: ITGWorkoutKit.WorkoutLoader

    public init(primary: ITGWorkoutKit.WorkoutLoader, fallback: ITGWorkoutKit.WorkoutLoader) {
        self.primary = primary
        self.fallback = fallback
    }

    public func load(completion: @escaping (ITGWorkoutKit.WorkoutLoader.Result) -> Void) {
        primary.load { [weak self] result in
            switch result {
            case .success:
                completion(result)
            case .failure:
                self?.fallback.load(completion: completion)
            }
        }
    }
}
