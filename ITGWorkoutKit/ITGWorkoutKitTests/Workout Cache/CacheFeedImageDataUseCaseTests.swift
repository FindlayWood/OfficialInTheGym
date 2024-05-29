//
//  CacheFeedImageDataUseCaseTests.swift
//  ITGWorkoutKitTests
//
//  Created by Findlay Wood on 29/05/2024.
//

import XCTest
import ITGWorkoutKit

final class CacheFeedImageDataUseCaseTests: XCTestCase {

    func test_init_doesNotMessageStoreUponCreation() {
        let (_, store) = makeSUT()

        XCTAssertTrue(store.receivedMessages.isEmpty)
    }

    func test_saveImageDataForURL_requestsImageDataInsertionForURL() {
        let (sut, store) = makeSUT()
        let path = anyPath()
        let data = anyData()

        sut.save(data, for: path) { _ in }

        XCTAssertEqual(store.receivedMessages, [.insert(data: data, for: path)])
    }

    // MARK: - Helpers

    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: LocalFeedImageDataLoader, store: FeedImageDataStoreSpy) {
        let store = FeedImageDataStoreSpy()
        let sut = LocalFeedImageDataLoader(store: store)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, store)
    }

}
