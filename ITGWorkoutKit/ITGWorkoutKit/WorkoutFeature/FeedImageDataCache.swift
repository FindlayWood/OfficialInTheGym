//
//  FeedImageDataCache.swift
//  ITGWorkoutKit
//
//  Created by Findlay Wood on 02/06/2024.
//

import Foundation

public protocol FeedImageDataCache {
    typealias Result = Swift.Result<Void, Error>

    func save(_ data: Data, for url: URL, completion: @escaping (Result) -> Void)
}
