//
//  FeedLoaderCacheDecorator.swift
//  InTheGym
//
//  Created by Findlay Wood on 02/06/2024.
//  Copyright © 2024 FindlayWood. All rights reserved.
//

import ITGWorkoutKit

public final class FeedLoaderCacheDecorator: ITGWorkoutKit.WorkoutLoader {
    private let decoratee: ITGWorkoutKit.WorkoutLoader
    private let cache: FeedCache

    public init(decoratee: ITGWorkoutKit.WorkoutLoader, cache: FeedCache) {
        self.decoratee = decoratee
        self.cache = cache
    }

    public func load(completion: @escaping (ITGWorkoutKit.WorkoutLoader.Result) -> Void) {
        decoratee.load { [weak self] result in
            completion(result.map { feed in
                self?.cache.saveIgnoringResult(feed)
                return feed
            })
        }
    }
}

private extension FeedCache {
    func saveIgnoringResult(_ feed: [WorkoutItem]) {
        save(feed) { _ in }
    }
}
