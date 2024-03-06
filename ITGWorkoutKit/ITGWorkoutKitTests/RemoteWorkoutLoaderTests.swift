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
        
        XCTAssertNil(client.requestedPath)
    }
    
    func test_load_requestDataFromPath() {
        let path = "example/firestore/path"
        let (sut, client) = makeSUT(path: path)
        
        sut.load()
        
        XCTAssertEqual(client.requestedPath, path)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(path: String = "example/path") -> (sut: RemoteWorkoutLoader, client: FirestoreClientSpy) {
        let client = FirestoreClientSpy()
        let sut = RemoteWorkoutLoader(client: client, path: path)
        return (sut, client)
    }
    
    private class FirestoreClientSpy: FirestoreClient {
        var requestedPath: String?
        
        func get(from path: String) {
            requestedPath = path
        }
    }
    
}
