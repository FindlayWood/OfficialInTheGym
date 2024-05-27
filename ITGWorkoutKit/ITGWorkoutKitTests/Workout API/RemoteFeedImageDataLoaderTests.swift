//
//  RemoteFeedImageDataLoaderTests.swift
//  ITGWorkoutKitTests
//
//  Created by Findlay Wood on 27/05/2024.
//

import XCTest
import ITGWorkoutKit

class RemoteFeedImageDataLoader {
    
    private let client: Client

    init(client: Client) {
        self.client = client
    }

    func loadImageData(from path: String, completion: @escaping (FeedImageDataLoader.Result) -> Void) {
        client.get(from: path) { result in
            switch result {
            case let .failure(error): completion(.failure(error))
            default: break
            }
        }
    }
}

class RemoteFeedImageDataLoaderTests: XCTestCase {

    func test_init_doesNotPerformAnyURLRequest() {
        let (_, client) = makeSUT()

        XCTAssertTrue(client.requestedPaths.isEmpty)
    }
    
    func test_loadImageDataFromURL_requestsDataFromURL() {
        let path =  "https://a-given-url.com"
        let (sut, client) = makeSUT(path: path)

        sut.loadImageData(from: path) { _ in }

        XCTAssertEqual(client.requestedPaths, [path])
    }
    
    func test_loadImageDataFromURLTwice_requestsDataFromURLTwice() {
        let path =  "https://a-given-url.com"
        let (sut, client) = makeSUT(path: path)

        sut.loadImageData(from: path) { _ in }
        sut.loadImageData(from: path) { _ in }

        XCTAssertEqual(client.requestedPaths, [path, path])
    }
    
    func test_loadImageDataFromURL_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()
        let clientError = NSError(domain: "a client error", code: 0)

        expect(sut, toCompleteWith: .failure(clientError), when: {
            client.complete(with: clientError)
        })
    }

    // MARK: - Helpers
    private func makeSUT(path: String = "Any String", file: StaticString = #file, line: UInt = #line) -> (sut: RemoteFeedImageDataLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedImageDataLoader(client: client)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(client, file: file, line: line)
        return (sut, client)
    }
    
    private func expect(_ sut: RemoteFeedImageDataLoader, toCompleteWith expectedResult: FeedImageDataLoader.Result, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        let path =  "https://a-given-url.com"
        let exp = expectation(description: "Wait for load completion")

        sut.loadImageData(from: path) { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedData), .success(expectedData)):
                XCTAssertEqual(receivedData, expectedData, file: file, line: line)

            case let (.failure(receivedError as NSError), .failure(expectedError as NSError)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)

            default:
                XCTFail("Expected result \(expectedResult) got \(receivedResult) instead", file: file, line: line)
            }

            exp.fulfill()
        }

        action()

        wait(for: [exp], timeout: 1.0)
    }

    private class HTTPClientSpy: Client {
        
        private var messages = [(path: String, completion: (Client.Result) -> Void)]()
        
        var requestedPaths: [String] {
            messages.map { $0.path }
        }
        
        func get(from path: String, completion: @escaping (Client.Result) -> Void) {
            messages.append((path, completion))
        }
        
        func complete(with error: Error, at index: Int = 0) {
            messages[index].completion(.failure(error))
        }
    }
}
