//
//  FeedImageDataLoader.swift
//  ITGWorkoutKitiOS
//
//  Created by Findlay Wood on 21/04/2024.
//

import Foundation

public protocol FeedImageDataLoaderTask {
    func cancel()
}

public protocol FeedImageDataLoader {
    typealias Result = Swift.Result<Data, Error>

    func loadImageData(from url: URL, completion: @escaping (Result) -> Void) -> FeedImageDataLoaderTask
}
