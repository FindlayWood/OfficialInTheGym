//
//  ClientSpy.swift
//  ITGWorkoutKitTests
//
//  Created by Findlay Wood on 26/05/2024.
//

import Foundation
import ITGWorkoutKit

class ClientSpy: Client {
    
    private struct Task: HTTPClientTask {
        func cancel() {}
    }
    
    private var messages = [(path: String, completion: (Client.Result) -> Void)]()
    
    var requestedPaths: [String] {
        messages.map { $0.path }
    }
    
    func get(from path: String, completion: @escaping (Client.Result) -> Void) -> HTTPClientTask {
        messages.append((path, completion))
        return Task()
    }
    
    func complete(with error: Error, at index: Int = 0) {
        messages[index].completion(.failure(error))
    }
    
    func complete(withStatusCode statusCode: Int, data: Data, at index: Int = 0) {
        let response = HTTPURLResponse(url: URL(string: "Example.com")!,
                                       statusCode: statusCode,
                                       httpVersion: nil,
                                       headerFields: nil)!
        messages[index].completion(.success((data, response)))
    }
}
