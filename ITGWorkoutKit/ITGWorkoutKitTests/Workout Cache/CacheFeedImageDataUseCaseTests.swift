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
    
    
    func test_saveImageDataFromURL_failsOnStoreInsertionError() {
        let (sut, store) = makeSUT()

        expect(sut, toCompleteWith: failed(), when: {
            let insertionError = anyNSError()
            store.completeInsertion(with: insertionError)
        })
    }
    
    func test_saveImageDataFromURL_succeedsOnSuccessfulStoreInsertion() {
        let (sut, store) = makeSUT()

        expect(sut, toCompleteWith: .success(()), when: {
            store.completeInsertionSuccessfully()
        })
    }

    // MARK: - Helpers

    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: LocalFeedImageDataLoader, store: FeedImageDataStoreSpy) {
        let store = FeedImageDataStoreSpy()
        let sut = LocalFeedImageDataLoader(store: store)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, store)
    }
    
    private func failed() -> LocalFeedImageDataLoader.SaveResult {
        return .failure(LocalFeedImageDataLoader.SaveError.failed)
    }

    private func expect(_ sut: LocalFeedImageDataLoader, toCompleteWith expectedResult: LocalFeedImageDataLoader.SaveResult, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Wait for load completion")

        sut.save(anyData(), for: anyPath()) { receivedResult in
            switch (receivedResult, expectedResult) {
            case (.success, .success):
                break

            case (.failure(let receivedError as LocalFeedImageDataLoader.SaveError),
                  .failure(let expectedError as LocalFeedImageDataLoader.SaveError)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)

            default:
                XCTFail("Expected result \(expectedResult), got \(receivedResult) instead", file: file, line: line)
            }

            exp.fulfill()
        }

        action()
        wait(for: [exp], timeout: 1.0)
    }

}
