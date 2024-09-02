//
//  LoadWorkoutsFromRemoteUseCaseTests.swift
//  ITGWorkoutKitTests
//
//  Created by Findlay Wood on 03/05/2024.
//

import XCTest
import ITGWorkoutKit

class LoadWorkoutsFromRemoteUseCaseTests: XCTestCase {
    
    
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
        
        let item1Date = Date(timeIntervalSince1970: 1598627222)
        let item1isoDate = item1Date.ISO8601Format()
        let item1 = makeItem(
            id: UUID().uuidString,
            title: "Momday",
            exerciseCount: 3,
            createdUID: "james",
            createdDate: (item1Date, item1isoDate),
            addedToListDate: (item1Date, item1isoDate))
        
        let item2Date = Date(timeIntervalSince1970: 1577881882)
        let item2isoDate = item2Date.ISO8601Format()
        let item2 = makeItem(
            id: UUID().uuidString,
            title: "Wednesday",
            exerciseCount: 6,
            createdUID: "steven",
            createdDate: (item2Date,item2isoDate),
            addedToListDate: (item2Date,item2isoDate))
        
        
        let items = [item1.model, item2.model]

        expect(sut, toCompleteWith: .success(items), when: {
            let json = makeItemsJSON([item1.json, item2.json])
            client.complete(withStatusCode: 200, data: json)
        })
    }
    
    func test_load_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
        let client = ClientSpy()
        var sut: FirestoreWorkoutLoader? = FirestoreWorkoutLoader(client: client, path: "path/example")

        var capturedResults = [FirestoreWorkoutLoader.Result]()
        sut?.load { capturedResults.append($0) }

        sut = nil
        client.complete(withStatusCode: 200, data: makeItemsJSON([]))

        XCTAssertTrue(capturedResults.isEmpty)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(path: String = "example/path", file: StaticString = #filePath, line: UInt = #line) -> (sut: FirestoreWorkoutLoader, client: ClientSpy) {
        let client = ClientSpy()
        let sut = FirestoreWorkoutLoader(client: client, path: path)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(client, file: file, line: line)
        return (sut, client)
    }
    
    private func failure(_ error: FirestoreWorkoutLoader.Error) -> FirestoreWorkoutLoader.Result {
        return .failure(error)
    }
    
    private func makeItem(id: String, title: String, exerciseCount: Int, createdUID: String, createdDate: (date: Date, iso8601String: String), addedToListDate: (date: Date, iso8601String: String)) -> (model: WorkoutItem2, json: [String: Any]) {
        
        let item = WorkoutItem2(id: id, title: title, exerciseCount: exerciseCount, createdUID: createdUID, createdDate: createdDate.date, addedToListDate: addedToListDate.date)

        let json: [String: Any] = [
            "id": id,
            "title": title,
            "exerciseCount": exerciseCount,
            "createdUID": createdUID,
            "createdDate": createdDate.iso8601String,
            "addedToListDate": addedToListDate.iso8601String
        ]

        return (item, json)
    }
    
    private func makeItemsJSON(_ workouts: [[String: Any]]) -> Data {
        let json = ["workouts": workouts]
        return try! JSONSerialization.data(withJSONObject: json)
    }
    
    private func expect(_ sut: FirestoreWorkoutLoader, toCompleteWith expectedResult: FirestoreWorkoutLoader.Result, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        
        let exp = expectation(description: "Wait for load completion")
        
        sut.load { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedItems), .success(expectedItems)):
                XCTAssertEqual(receivedItems, expectedItems, file: file, line: line)
                
            case let (.failure(receivedError as FirestoreWorkoutLoader.Error), .failure(expectedError as FirestoreWorkoutLoader.Error)):
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
