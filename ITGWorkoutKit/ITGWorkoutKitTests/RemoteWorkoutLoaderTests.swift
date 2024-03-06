//
//  RemoteWorkoutLoaderTests.swift
//  ITGWorkoutKitTests
//
//  Created by Findlay Wood on 03/03/2024.
//

import XCTest

class RemoteWorkoutLoader {
    
    let client: FirestoreClient
    let path: String
    
    init(client: FirestoreClient, path: String) {
        self.client = client
        self.path = path
    }
    
    func load() {
        client.get(from: path)
    }
}

protocol FirestoreClient {
    func get(from path: String)
}

class FirestoreClientSpy: FirestoreClient {
    var requestedPath: String?
    
    func get(from path: String) {
        requestedPath = path
    }
}

class RemoteWorkoutLoaderTests: XCTestCase {
    
    
    func test_init_doesNotRequestDataFromPath() {
        let path = "example/path"
        let client = FirestoreClientSpy()
        let sut = RemoteWorkoutLoader(client: client, path: path)
        
        
        XCTAssertNil(client.requestedPath)
    }
    
    func test_load_requestDataFromPath() {
        let path = "example/firestore/path"
        let client = FirestoreClientSpy()
        let sut = RemoteWorkoutLoader(client: client, path: path)
        
        sut.load()
        
        XCTAssertEqual(client.requestedPath, path)
    }
}
