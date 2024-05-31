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

    init(primary: WorkoutLoader, fallback: WorkoutLoader) {
        self.primary = primary
    }

    func load(completion: @escaping (WorkoutLoader.Result) -> Void) {
        primary.load(completion: completion)
    }
}

class FeedLoaderWithFallbackCompositeTests: XCTestCase {

    func test_load_deliversPrimaryFeedOnPrimaryLoaderSuccess() {
        let primaryFeed = uniqueFeed()
        let fallbackFeed = uniqueFeed()
        let primaryLoader = LoaderStub(result: .success(primaryFeed))
        let fallbackLoader = LoaderStub(result: .success(fallbackFeed))
        let sut = FeedLoaderWithFallbackComposite(primary: primaryLoader, fallback: fallbackLoader)

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
