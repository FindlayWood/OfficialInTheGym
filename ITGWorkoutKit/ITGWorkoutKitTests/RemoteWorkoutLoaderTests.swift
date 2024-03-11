//
//  RemoteWorkoutLoaderTests.swift
//  ITGWorkoutKitTests
//
//  Created by Findlay Wood on 03/03/2024.
//

import XCTest
import ITGWorkoutKit

class RemoteWorkoutLoaderTests: XCTestCase {
    
    
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
        
        expect(sut, toCompleteWith: .failure(.connectivity)) {
            let clientError = NSError(domain: "Test", code: 0)
            
            client.complete(with: clientError)
        }
    }
    
    func test_load_deliversErrorOnNon200HTTPResponse() {
        let (sut, client) = makeSUT()
        
        let samples = [199, 201, 300, 400, 500]
        
        samples.enumerated().forEach { index, code in
            
            expect(sut, toCompleteWith: .failure(.invalidData)) {
                client.complete(withStatusCode: code, at: index)
            }
        }
    }
    
    func test_load_deliversErrorOnResponseWithInvalidJson() {
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWith: .failure(.invalidData)) {
            let invalidJSON = Data("Invalid json".utf8)
            client.complete(withStatusCode: 200, data: invalidJSON)
        }
    }
    
    func test_load_deliversNoItemsResponseWithEmptyList() {
        
        let (sut, client) = makeSUT()

        expect(sut, toCompleteWith: .success([]), when: {
            let emptyJSONList = Data("{\"items\": []}".utf8)
            client.complete(withStatusCode: 200, data: emptyJSONList)
        })
    }
    
    func test_load_deliversItemsOn200HTTPResponseWithJSONItems() {
        
        let (sut, client) = makeSUT()
        
        let item1 = WorkoutItem(
            id: UUID().uuidString,
            title: "example 1")
        
        let item1JSON = [
            "id": item1.id,
            "title": item1.title
        ]
        
        let item2 = WorkoutItem(
            id: UUID().uuidString,
            title: "example 2")
        
        let item2JSON = [
            "id": item2.id,
            "title": item2.title
        ]
        
        let itemsJSON = [
            "items": [item1JSON, item2JSON]
        ]

        expect(sut, toCompleteWith: .success([item1, item2]), when: {
            let json = try! JSONSerialization.data(withJSONObject: itemsJSON)
            client.complete(withStatusCode: 200, data: json)
        })
    }
    
    // MARK: - Helpers
    
    private func makeSUT(path: String = "example/path") -> (sut: RemoteWorkoutLoader, client: ClientSpy) {
        let client = ClientSpy()
        let sut = RemoteWorkoutLoader(client: client, path: path)
        return (sut, client)
    }
    
    private func expect(_ sut: RemoteWorkoutLoader, toCompleteWith result: RemoteWorkoutLoader.Result, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        
        var capturedResults = [RemoteWorkoutLoader.Result]()
        sut.load { capturedResults.append($0) }
        
        action()
        
        XCTAssertEqual(capturedResults, [result], file: file, line: line)
        
    }
    
    private class ClientSpy: Client {
        
        private var messages = [(path: String, completion: (ClientResult) -> Void)]()
        
        var requestedPaths: [String] {
            messages.map { $0.path }
        }
        
        func get(from path: String, completion: @escaping (ClientResult) -> Void) {
            messages.append((path, completion))
        }
        
        func complete(with error: Error, at index: Int = 0) {
            messages[index].completion(.failure(error))
        }
        
        func complete(withStatusCode statusCode: Int, data: Data = Data(), at index: Int = 0) {
            let response = HTTPURLResponse(url: URL(string: "Example.com")!,
                                           statusCode: statusCode,
                                           httpVersion: nil,
                                           headerFields: nil)!
            messages[index].completion(.success(data, response))
        }
    }
    
}
