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
            if let error = error {
                completion(.failure(error))
            } else if let data = data, let response = response as? HTTPURLResponse {
                completion(.success((data, response)))
            } else {
                completion(.failure(UnexpectedValuesRepresentation()))
            }
        }.resume()
    }
}
