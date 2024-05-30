//
//  MainQueueDispatchDecorator.swift
//  ITGWorkoutKitiOS
//
//  Created by Findlay Wood on 28/04/2024.
//

import Foundation
import ITGWorkoutKit

final class MainQueueDispatchDecorator<T> {
    private let decoratee: T
    
    init(decoratee: T) {
        self.decoratee = decoratee
    }
    
    func dispatch(completion: @escaping () -> Void) {
        guard Thread.isMainThread else {
            return DispatchQueue.main.async(execute: completion)
        }
        
        completion()
    }
}

extension MainQueueDispatchDecorator: WorkoutLoader where T == WorkoutLoader {

    func load(completion: @escaping (WorkoutLoader.Result) -> Void) {
        decoratee.load { [weak self] result in
            self?.dispatch { completion(result) }
        }
    }
}


extension MainQueueDispatchDecorator: FeedImageDataLoader where T == FeedImageDataLoader {
    
    func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        return decoratee.loadImageData(from: url) { [weak self] result in
            self?.dispatch { completion(result) }
        }
    }
}
