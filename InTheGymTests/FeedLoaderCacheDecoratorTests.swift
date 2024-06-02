//
//  FeedLoaderCacheDecoratorTests.swift
//  InTheGymTests
//
//  Created by Findlay Wood on 02/06/2024.
//  Copyright © 2024 FindlayWood. All rights reserved.
//

import XCTest
import ITGWorkoutKit

protocol FeedCache {
    typealias Result = Swift.Result<Void, Error>

    func save(_ feed: [WorkoutItem], completion: @escaping (Result) -> Void)
}

final class FeedLoaderCacheDecorator: WorkoutLoader {
    private let decoratee: WorkoutLoader
    private let cache: FeedCache

    init(decoratee: WorkoutLoader, cache: FeedCache) {
        self.decoratee = decoratee
        self.cache = cache
    }

    func load(completion: @escaping (WorkoutLoader.Result) -> Void) {
        decoratee.load { [weak self] result in
            self?.cache.save((try? result.get()) ?? []) { _ in }
            completion(result)
        }
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
    
    func test_load_cachesLoadedFeedOnLoaderSuccess() {
        let cache = CacheSpy()
        let feed = uniqueFeed()
        let sut = makeSUT(loaderResult: .success(feed), cache: cache)

        sut.load { _ in }

        XCTAssertEqual(cache.messages, [.save(feed)], "Expected to cache loaded feed on success")
    }
    
    // MARK: - Helpers

    private func makeSUT(loaderResult: WorkoutLoader.Result, cache: CacheSpy = .init(), file: StaticString = #file, line: UInt = #line) -> WorkoutLoader {
        let loader = FeedLoaderStub(result: loaderResult)
        let sut = FeedLoaderCacheDecorator(decoratee: loader, cache: cache)
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    private class CacheSpy: FeedCache {
        private(set) var messages = [Message]()

        enum Message: Equatable {
            case save([WorkoutItem])
        }

        func save(_ feed: [WorkoutItem], completion: @escaping (FeedCache.Result) -> Void) {
            messages.append(.save(feed))
            completion(.success(()))
        }
    }
}
