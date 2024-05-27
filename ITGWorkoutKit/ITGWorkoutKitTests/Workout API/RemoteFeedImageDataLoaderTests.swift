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

    func loadImageData(from path: String, completion: @escaping (Any) -> Void) {
        client.get(from: path) { _ in }
    }
}

class RemoteFeedImageDataLoaderTests: XCTestCase {

    func test_init_doesNotPerformAnyURLRequest() {
        let (_, client) = makeSUT()

        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    func test_loadImageDataFromURL_requestsDataFromURL() {
        let path =  "https://a-given-url.com"
        let (sut, client) = makeSUT(path: path)

        sut.loadImageData(from: path) { _ in }

        XCTAssertEqual(client.requestedURLs, [path])
    }

    private func makeSUT(path: String = "Any String", file: StaticString = #file, line: UInt = #line) -> (sut: RemoteFeedImageDataLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedImageDataLoader(client: client)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(client, file: file, line: line)
        return (sut, client)
    }

    private class HTTPClientSpy: Client {
        var requestedURLs = [String]()
        
        func get(from path: String, completion: @escaping (Client.Result) -> Void) {
            requestedURLs.append(path)
        }
    }
}
