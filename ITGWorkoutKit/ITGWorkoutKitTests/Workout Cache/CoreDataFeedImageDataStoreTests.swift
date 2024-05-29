//
//  CoreDataFeedImageDataStoreTests.swift
//  ITGWorkoutKitTests
//
//  Created by Findlay Wood on 29/05/2024.
//

import XCTest
import ITGWorkoutKit

class CoreDataFeedImageDataStoreTests: XCTestCase {

    func test_retrieveImageData_deliversNotFoundWhenEmpty() {
        let sut = makeSUT()

        expect(sut, toCompleteRetrievalWith: notFound(), for: anyPath())
    }
    
    func test_retrieveImageData_deliversNotFoundWhenStoredDataURLDoesNotMatch() {
        let sut = makeSUT()
        let path = "http://a-url.com"
        let nonMatchingPath = "http://another-url.com"

        insert(anyData(), for: path, into: sut)

        expect(sut, toCompleteRetrievalWith: notFound(), for: nonMatchingPath)
    }
    
    
    func test_retrieveImageData_deliversFoundDataWhenThereIsAStoredImageDataMatchingURL() {
        let sut = makeSUT()
        let storedData = anyData()
        let matchingPath = "http://a-url.com"

        insert(storedData, for: matchingPath, into: sut)

        expect(sut, toCompleteRetrievalWith: found(storedData), for: matchingPath)
    }
    
    func test_retrieveImageData_deliversLastInsertedValue() {
        let sut = makeSUT()
        let firstStoredData = Data("first".utf8)
        let lastStoredData = Data("last".utf8)
        let path = "http://a-url.com"

        insert(firstStoredData, for: path, into: sut)
        insert(lastStoredData, for: path, into: sut)

        expect(sut, toCompleteRetrievalWith: found(lastStoredData), for: path)
    }
    
    func test_sideEffects_runSerially() {
        let sut = makeSUT()
        let path = anyPath()

        let op1 = expectation(description: "Operation 1")
        sut.insert([localImage(path: path)], timestamp: Date()) { _ in
            op1.fulfill()
        }

        let op2 = expectation(description: "Operation 2")
        sut.insert(anyData(), for: path) { _ in    op2.fulfill() }

        let op3 = expectation(description: "Operation 3")
        sut.insert(anyData(), for: path) { _ in op3.fulfill() }

        wait(for: [op1, op2, op3], timeout: 5.0, enforceOrder: true)
    }

    // - MARK: Helpers

    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> CoreDataFeedStore {
        let storeURL = URL(fileURLWithPath: "/dev/null")
        let sut = try! CoreDataFeedStore(storeURL: storeURL)
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }

    private func notFound() -> FeedImageDataStore.RetrievalResult {
        return .success(.none)
    }
    
    private func found(_ data: Data) -> FeedImageDataStore.RetrievalResult {
        return .success(data)
    }
    
    private func localImage(path: String) -> LocalWorkoutItem {
        return LocalWorkoutItem(id: UUID(), description: "any", location: "any", image: URL(string: path))
    }

    private func expect(_ sut: CoreDataFeedStore, toCompleteRetrievalWith expectedResult: FeedImageDataStore.RetrievalResult, for path: String,  file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Wait for load completion")
        sut.retrieve(dataForPath: path) { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success( receivedData), .success(expectedData)):
                XCTAssertEqual(receivedData, expectedData, file: file, line: line)

            default:
                XCTFail("Expected \(expectedResult), got \(receivedResult) instead", file: file, line: line)
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
    
    private func insert(_ data: Data, for path: String, into sut: CoreDataFeedStore, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Wait for cache insertion")
        let image = localImage(path: path)
        sut.insert([image], timestamp: Date()) { result in
            switch result {
            case let .failure(error):
                XCTFail("Failed to save \(image) with error \(error)", file: file, line: line)
                
                exp.fulfill()

            case .success:
                sut.insert(data, for: path) { result in
                    if case let Result.failure(error) = result {
                        XCTFail("Failed to insert \(data) with error \(error)", file: file, line: line)
                    }
                    exp.fulfill()
                }
            }
        }
        wait(for: [exp], timeout: 1.0)
    }

}
