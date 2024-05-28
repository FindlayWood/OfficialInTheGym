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
    
    public enum Error: Swift.Error {
        case invalidData
    }

    init(client: Client) {
        self.client = client
    }
    
    private final class HTTPClientTaskWrapper: FeedImageDataLoaderTask {
        
        private var completion: ((FeedImageDataLoader.Result) -> Void)?

        var wrapped: HTTPClientTask?

        init(_ completion: @escaping (FeedImageDataLoader.Result) -> Void) {
            self.completion = completion
        }

        func complete(with result: FeedImageDataLoader.Result) {
            completion?(result)
        }
        

        func cancel() {
            preventFurtherCompletions()
            wrapped?.cancel()
        }
        
        private func preventFurtherCompletions() {
            completion = nil
        }
    }

    @discardableResult
    func loadImageData(from path: String, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        let task = HTTPClientTaskWrapper(completion)
        
        task.wrapped = client.get(from: path) { [weak self] result in
            guard self != nil else { return }
            switch result {
            case let .success((data, response)):
                if response.statusCode == 200, !data.isEmpty {
                    task.complete(with: .success(data))
                } else {
                    task.complete(with: .failure(Error.invalidData))
                }
            case let .failure(error): task.complete(with: .failure(error))
            }
        }
        
        return task
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
    
    func test_loadImageDataFromURL_deliversInvalidDataErrorOnNon200HTTPResponse() {
        let (sut, client) = makeSUT()

        let samples = [199, 201, 300, 400, 500]

        samples.enumerated().forEach { index, code in
            expect(sut, toCompleteWith: failure(.invalidData), when: {
                client.complete(withStatusCode: code, data: anyData(), at: index)
            })
        }
    }
    
    func test_loadImageDataFromURL_deliversInvalidDataErrorOn200HTTPResponseWithEmptyData() {
        let (sut, client) = makeSUT()

        expect(sut, toCompleteWith: failure(.invalidData), when: {
            let emptyData = Data()
            client.complete(withStatusCode: 200, data: emptyData)
        })
    }
    
    func test_loadImageDataFromURL_deliversReceivedNonEmptyDataOn200HTTPResponse() {
        let (sut, client) = makeSUT()
        let nonEmptyData = Data("non-empty data".utf8)

        expect(sut, toCompleteWith: .success(nonEmptyData), when: {
            client.complete(withStatusCode: 200, data: nonEmptyData)
        })
    }
    
    func test_cancelLoadImageDataURLTask_cancelsClientURLRequest() {
        let (sut, client) = makeSUT()
        let path =  "https://a-given-url.com"

        let task = sut.loadImageData(from: path) { _ in }
        XCTAssertTrue(client.cancelledPaths.isEmpty, "Expected no cancelled URL request until task is cancelled")

        task.cancel()
        XCTAssertEqual(client.cancelledPaths, [path], "Expected cancelled URL request after task is cancelled")
    }
    
    func test_loadImageDataFromURL_doesNotDeliverResultAfterCancellingTask() {
        let path =  "https://a-given-url.com"
        let (sut, client) = makeSUT()
        let nonEmptyData = Data("non-empty data".utf8)

        var received = [FeedImageDataLoader.Result]()
        let task = sut.loadImageData(from: path) { received.append($0) }
        task.cancel()

        client.complete(withStatusCode: 404, data: anyData())
        client.complete(withStatusCode: 200, data: nonEmptyData)
        client.complete(with: anyNSError())

        XCTAssertTrue(received.isEmpty, "Expected no received results after cancelling task")
    }
    
    func test_loadImageDataFromURL_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
        let path =  "https://a-given-url.com"
        let client = HTTPClientSpy()
        var sut: RemoteFeedImageDataLoader? = RemoteFeedImageDataLoader(client: client)

        var capturedResults = [FeedImageDataLoader.Result]()
        sut?.loadImageData(from: path) { capturedResults.append($0) }

        sut = nil
        client.complete(withStatusCode: 200, data: anyData())

        XCTAssertTrue(capturedResults.isEmpty)
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

            case let (.failure(receivedError as RemoteFeedImageDataLoader.Error), .failure(expectedError as RemoteFeedImageDataLoader.Error)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)

                
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
    
    private func failure(_ error: RemoteFeedImageDataLoader.Error) -> FeedImageDataLoader.Result {
        return .failure(error)
    }

    private class HTTPClientSpy: Client {
        
        private struct Task: HTTPClientTask {
            let callback: () -> Void
            func cancel() { callback() }
        }
        
        private var messages = [(path: String, completion: (Client.Result) -> Void)]()
        private(set) var cancelledPaths = [String]()
        
        var requestedPaths: [String] {
            messages.map { $0.path }
        }
        
        func get(from path: String, completion: @escaping (Client.Result) -> Void) -> HTTPClientTask {
            messages.append((path, completion))
            return Task { [weak self] in
                self?.cancelledPaths.append(path)
            }
        }
        
        func complete(with error: Error, at index: Int = 0) {
            messages[index].completion(.failure(error))
        }
        
        func complete(withStatusCode code: Int, data: Data, at index: Int = 0) {
            let response = HTTPURLResponse(
                url: URL(string: requestedPaths[index])!,
                statusCode: code,
                httpVersion: nil,
                headerFields: nil
            )!
            messages[index].completion(.success((data, response)))
        }
    }
}
