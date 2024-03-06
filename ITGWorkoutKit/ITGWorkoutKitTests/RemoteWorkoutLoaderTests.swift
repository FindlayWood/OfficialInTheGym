//
//  RemoteWorkoutLoaderTests.swift
//  ITGWorkoutKitTests
//
//  Created by Findlay Wood on 03/03/2024.
//

import XCTest

class RemoteWorkoutLoader {
    
    let client: FirestoreClient
    
    init(client: FirestoreClient) {
        self.client = client
    }
    
    func load() {
        client.get(from: "examplepath")
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
        
        let client = FirestoreClientSpy()
        let sut = RemoteWorkoutLoader(client: client)
        
        
        XCTAssertNil(client.requestedPath)
    }
    
    func test_load_requestDataFromPath() {
        
        let client = FirestoreClientSpy()
        let sut = RemoteWorkoutLoader(client: client)
        
        sut.load()
        
        XCTAssertNotNil(client.requestedPath)
    }
}
