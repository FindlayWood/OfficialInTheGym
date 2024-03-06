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
        
        sut.load()
        
        XCTAssertEqual(client.requestedPaths, [path])
    }
    
    func test_loadTwice_requestDataFromPathTwice() {
        let path = "example/firestore/path"
        let (sut, client) = makeSUT(path: path)
        
        sut.load()
        sut.load()
        
        XCTAssertEqual(client.requestedPaths, [path, path])
    }
    
    // MARK: - Helpers
    
    private func makeSUT(path: String = "example/path") -> (sut: RemoteWorkoutLoader, client: FirestoreClientSpy) {
        let client = FirestoreClientSpy()
        let sut = RemoteWorkoutLoader(client: client, path: path)
        return (sut, client)
    }
    
    private class FirestoreClientSpy: FirestoreClient {
        var requestedPaths: [String] = []
        
        func get(from path: String) {
            requestedPaths.append(path)
        }
    }
    
}
