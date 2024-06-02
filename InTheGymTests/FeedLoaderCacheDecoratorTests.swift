//
//  FeedLoaderCacheDecoratorTests.swift
//  InTheGymTests
//
//  Created by Findlay Wood on 02/06/2024.
//  Copyright © 2024 FindlayWood. All rights reserved.
//

import XCTest
import ITGWorkoutKit

final class FeedLoaderCacheDecorator: WorkoutLoader {
    private let decoratee: WorkoutLoader

    init(decoratee: WorkoutLoader) {
        self.decoratee = decoratee
    }

    func load(completion: @escaping (WorkoutLoader.Result) -> Void) {
        decoratee.load(completion: completion)
    }
}

class FeedLoaderCacheDecoratorTests: XCTestCase, FeedLoaderTestCase {

    func test_load_deliversFeedOnLoaderSuccess() {
        let feed = uniqueFeed()
        let sut = makeSUT(loaderResult: .success(feed))

        expect(sut, toCompleteWith: .success(feed))
    }

    func test_load_deliversErrorOnLoaderFailure() {
        let sut = makeSUT(loaderResult: .failure(anyNSError()))

        expect(sut, toCompleteWith: .failure(anyNSError()))
    }
    
    // MARK: - Helpers

    private func makeSUT(loaderResult: WorkoutLoader.Result, file: StaticString = #file, line: UInt = #line) -> WorkoutLoader {
        let loader = FeedLoaderStub(result: loaderResult)
        let sut = FeedLoaderCacheDecorator(decoratee: loader)
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
}
