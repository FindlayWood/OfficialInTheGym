//
//  LocalFeedImageDataLoaderTests.swift
//  ITGWorkoutKitTests
//
//  Created by Findlay Wood on 29/05/2024.
//

import XCTest
import ITGWorkoutKit

protocol FeedImageDataStore {
    func retrieve(dataForPath path: String)
}

final class LocalFeedImageDataLoader: FeedImageDataLoader {
    private struct Task: FeedImageDataLoaderTask {
        func cancel() {}
    }

    private let store: FeedImageDataStore

    init(store: FeedImageDataStore) {
        self.store = store
    }

    func loadImageData(from path: String, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        store.retrieve(dataForPath: path)
        return Task()
    }
}

class LocalFeedImageDataLoaderTests: XCTestCase {

    func test_init_doesNotMessageStoreUponCreation() {
        let (_, store) = makeSUT()

        XCTAssertTrue(store.receivedMessages.isEmpty)
    }
    
    func test_loadImageDataFromURL_requestsStoredDataForURL() {
        let (sut, store) = makeSUT()
        let path = anyPath()

        _ = sut.loadImageData(from: path) { _ in }

        XCTAssertEqual(store.receivedMessages, [.retrieve(dataFor: path)])
    }

    // MARK: - Helpers

    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #file, line: UInt = #line) -> (sut: LocalFeedImageDataLoader, store: StoreSpy) {
        let store = StoreSpy()
        let sut = LocalFeedImageDataLoader(store: store)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, store)
    }

    private class StoreSpy: FeedImageDataStore {
        enum Message: Equatable {
            case retrieve(dataFor: String)
        }

        private(set) var receivedMessages = [Message]()

        func retrieve(dataForPath path: String) {
            receivedMessages.append(.retrieve(dataFor: path))
        }
    }

}
