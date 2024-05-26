//
//  RemoteLoaderTests.swift
//  ITGWorkoutKitTests
//
//  Created by Findlay Wood on 26/05/2024.
//

import XCTest
import ITGWorkoutKit

final class RemoteLoaderTests: XCTestCase {
    
    func test_init_doesNotRequestDataFromPath() {
        let (_, client) = makeSUT()
        
        XCTAssertTrue(client.requestedPaths.isEmpty)
    }
    
    func test_load_requestDataFromPath() {
        let path = "example/firestore/path"
        let (sut, client) = makeSUT(path: path)
        
        sut.load { _ in }
        
        XCTAssertEqual(client.requestedPaths, [path])
    }
    
    func test_loadTwice_requestDataFromPathTwice() {
        let path = "example/firestore/path"
        let (sut, client) = makeSUT(path: path)
        
        sut.load { _ in }
        sut.load { _ in }
        
        XCTAssertEqual(client.requestedPaths, [path, path])
    }
    
    func test_load_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWith: failure(.connectivity)) {
            let clientError = NSError(domain: "Test", code: 0)
            
            client.complete(with: clientError)
        }
    }
    
    func test_load_deliversErrorOnNon200HTTPResponse() {
        let (sut, client) = makeSUT()
        
        let samples = [199, 201, 300, 400, 500]
        
        samples.enumerated().forEach { index, code in
            
            expect(sut, toCompleteWith: failure(.invalidData)) {
                let json = makeItemsJSON([])
                client.complete(withStatusCode: code, data: json, at: index)
            }
        }
    }
    
    func test_load_deliversErrorOnResponseWithInvalidJson() {
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWith: failure(.invalidData)) {
            let invalidJSON = Data("Invalid json".utf8)
            client.complete(withStatusCode: 200, data: invalidJSON)
        }
    }
    
    func test_load_deliversNoItemsResponseWithEmptyList() {
        
        let (sut, client) = makeSUT()

        expect(sut, toCompleteWith: .success([]), when: {
            let emptyJSONList = makeItemsJSON([])
            client.complete(withStatusCode: 200, data: emptyJSONList)
        })
    }
    
    func test_load_deliversItemsOn200HTTPResponseWithJSONItems() {
        
        let (sut, client) = makeSUT()
        
        let item1 = makeItem(
            id: UUID(),
            image: URL(string: "http://a-url.com")!)
        
        let item2 = makeItem(
            id: UUID(),
            description: "example 2",
            location: "a location",
            image: URL(string: "http://another-url.com")!)
        
        
        let items = [item1.model, item2.model]

        expect(sut, toCompleteWith: .success(items), when: {
            let json = makeItemsJSON([item1.json, item2.json])
            client.complete(withStatusCode: 200, data: json)
        })
    }
    
    func test_load_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
        let client = ClientSpy()
        var sut: RemoteLoader? = RemoteLoader(client: client, path: "path/example")

        var capturedResults = [RemoteLoader.Result]()
        sut?.load { capturedResults.append($0) }

        sut = nil
        client.complete(withStatusCode: 200, data: makeItemsJSON([]))

        XCTAssertTrue(capturedResults.isEmpty)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(path: String = "example/path", file: StaticString = #filePath, line: UInt = #line) -> (sut: RemoteLoader, client: ClientSpy) {
        let client = ClientSpy()
        let sut = RemoteLoader(client: client, path: path)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(client, file: file, line: line)
        return (sut, client)
    }
    
    private func failure(_ error: RemoteLoader.Error) -> RemoteLoader.Result {
        return .failure(error)
    }
    
    private func makeItem(id: UUID, description: String? = nil, location: String? = nil, image: URL) -> (model: WorkoutItem, json: [String: Any]) {
        
        let item = WorkoutItem(id: id, description: description, location: location, image: image)

        let json = [
            "id": id.uuidString,
            "description": description,
            "location": location,
            "image": image.absoluteString
        ].compactMapValues { $0 }

        return (item, json)
    }
    
    private func makeItemsJSON(_ items: [[String: Any]]) -> Data {
        let json = ["items": items]
        return try! JSONSerialization.data(withJSONObject: json)
    }
    
    private func expect(_ sut: RemoteLoader, toCompleteWith expectedResult: RemoteLoader.Result, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        
        let exp = expectation(description: "Wait for load completion")
        
        sut.load { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedItems), .success(expectedItems)):
                XCTAssertEqual(receivedItems, expectedItems, file: file, line: line)
                
            case let (.failure(receivedError as RemoteLoader.Error), .failure(expectedError as RemoteLoader.Error)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
                
            default:
                XCTFail("Expected result \(expectedResult) got \(receivedResult) instead", file: file, line: line)
            }
            
            exp.fulfill()
        }
        
        action()
        wait(for: [exp], timeout: 1.0)
        
    }
}
