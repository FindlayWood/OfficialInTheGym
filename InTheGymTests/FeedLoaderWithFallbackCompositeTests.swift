//
//  FeedLoaderWithFallbackCompositeTests.swift
//  InTheGymTests
//
//  Created by Findlay Wood on 31/05/2024.
//  Copyright © 2024 FindlayWood. All rights reserved.
//

import XCTest
import ITGWorkoutKit

class FeedLoaderWithFallbackComposite: WorkoutLoader {
    private let primary: WorkoutLoader
    private let fallback: WorkoutLoader

    init(primary: WorkoutLoader, fallback: WorkoutLoader) {
        self.primary = primary
        self.fallback = fallback
    }

    func load(completion: @escaping (WorkoutLoader.Result) -> Void) {
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

class FeedLoaderWithFallbackCompositeTests: XCTestCase {

    func test_load_deliversPrimaryFeedOnPrimaryLoaderSuccess() {
        let primaryFeed = uniqueFeed()
        let fallbackFeed = uniqueFeed()
        let sut = makeSUT(primaryResult: .success(primaryFeed), fallbackResult: .success(fallbackFeed))

        let exp = expectation(description: "Wait for load completion")
        sut.load { result in
            switch result {
            case let .success(receivedFeed):
                XCTAssertEqual(receivedFeed, primaryFeed)

            case .failure:
                XCTFail("Expected successful load feed result, got \(result) instead")
            }

            exp.fulfill()
        }
        wait(for: [exp], timeout: 1)
    }
    
    func test_load_deliversFallbackFeedOnPrimaryLoaderFailure() {
        let fallbackFeed = uniqueFeed()
        let sut = makeSUT(primaryResult: .failure(anyNSError()), fallbackResult: .success(fallbackFeed))

        let exp = expectation(description: "Wait for load completion")

        sut.load { result in
            switch result {
            case let .success(receivedFeed):
                XCTAssertEqual(receivedFeed, fallbackFeed)

            case .failure:
                XCTFail("Expected successful load feed result, got \(result) instead")
            }

            exp.fulfill()
        }

        wait(for: [exp], timeout: 1.0)
    }
    
    // MARK: - Helpers

    private func makeSUT(primaryResult: WorkoutLoader.Result, fallbackResult: WorkoutLoader.Result, file: StaticString = #file, line: UInt = #line) -> WorkoutLoader {
        let primaryLoader = LoaderStub(result: primaryResult)
        let fallbackLoader = LoaderStub(result: fallbackResult)
        let sut = FeedLoaderWithFallbackComposite(primary: primaryLoader, fallback: fallbackLoader)
        trackForMemoryLeaks(primaryLoader, file: file, line: line)
        trackForMemoryLeaks(fallbackLoader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }

    private func trackForMemoryLeaks(_ instance: AnyObject, file: StaticString = #file, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance should have been deallocated. Potential memory leak.", file: file, line: line)
        }
    }
    
    private func anyNSError() -> NSError {
        return NSError(domain: "any error", code: 0)
    }

    private func uniqueFeed() -> [WorkoutItem] {
        return [WorkoutItem(id: UUID(), description: "any", location: "any", image: URL(string: "http://any-url.com")!)]
    }

    private class LoaderStub: WorkoutLoader {
        private let result: WorkoutLoader.Result

        init(result: WorkoutLoader.Result) {
            self.result = result
        }

        func load(completion: @escaping (WorkoutLoader.Result) -> Void) {
            completion(result)
        }
    }

}
