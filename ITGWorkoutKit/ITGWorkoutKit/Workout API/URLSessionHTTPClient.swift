//
//  URLSessionHTTPClient.swift
//  ITGWorkoutKit
//
//  Created by Findlay Wood on 06/04/2024.
//

import Foundation

public class URLSessionHTTPClient: Client {
    private let session: URLSession

    public init(session: URLSession = .shared) {
        self.session = session
    }

    private struct UnexpectedValuesRepresentation: Error {}
    
    public func get(from path: String, completion: @escaping (Client.Result) -> Void) {
        session.dataTask(with: URL(string: path)!) { data, response, error in
            completion(Result {
                if let error = error {
                    throw error
                } else if let data = data, let response = response as? HTTPURLResponse {
                    return (data, response)
                } else {
                    throw UnexpectedValuesRepresentation()
                }
            })
        }.resume()
    }
}
