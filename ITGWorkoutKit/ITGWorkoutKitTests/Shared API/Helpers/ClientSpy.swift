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

class HTTPClientSpy: HTTPClient {
    
    private struct Task: HTTPClientTask {
        let callback: () -> Void
        func cancel() { callback() }
    }
    
    private var messages = [(url: URL, completion: (Client.Result) -> Void)]()
    private(set) var cancelledURLs = [URL]()
    
    var requestedURLs: [URL] {
        messages.map { $0.url }
    }
    
    func get(from url: URL, completion: @escaping (Client.Result) -> Void) -> HTTPClientTask {
        messages.append((url, completion))
        return Task { [weak self] in
            self?.cancelledURLs.append(url)
        }
    }
    
    func complete(with error: Error, at index: Int = 0) {
        messages[index].completion(.failure(error))
    }
    
    func complete(withStatusCode code: Int, data: Data, at index: Int = 0) {
        let response = HTTPURLResponse(
            url: requestedURLs[index],
            statusCode: code,
            httpVersion: nil,
            headerFields: nil
        )!
        messages[index].completion(.success((data, response)))
    }
}
