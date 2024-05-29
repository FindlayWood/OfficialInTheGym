//
//  FeedImageDataStore.swift
//  ITGWorkoutKit
//
//  Created by Findlay Wood on 29/05/2024.
//

import Foundation

public protocol FeedImageDataStore {
    typealias Result = Swift.Result<Data?, Error>
    typealias InsertionResult = Swift.Result<Void, Error>

    func insert(_ data: Data, for path: String, completion: @escaping (InsertionResult) -> Void)
    func retrieve(dataForPath path: String, completion: @escaping (Result) -> Void)
}
