//
//  RemoteWorkoutLoader.swift
//  ITGWorkoutKit
//
//  Created by Findlay Wood on 06/03/2024.
//

import Foundation

public enum ClientResult {
    case success(Data, HTTPURLResponse)
    case failure(Error)
}
public protocol Client {
    func get(from path: String, completion: @escaping (ClientResult) -> Void)
}

public final class RemoteWorkoutLoader {
    
    private let client: Client
    private let path: String
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public enum Result: Equatable {
        case success([WorkoutItem])
        case failure(Error)
    }
    
    public init(client: Client, path: String) {
        self.client = client
        self.path = path
    }
    
    public func load(completion: @escaping (Result) -> Void) {
        client.get(from: path) { result  in
            switch result {
            case let .success(data, response):
                do {
                    let items = try FeedItemsMapper.map(data, from: response)
                    completion(.success(items))
                } catch {
                    completion(.failure(.invalidData))
                }
            case .failure:
                completion(.failure(.connectivity))
            }
        }
    }
}

class FeedItemsMapper {
    private struct Root: Decodable {
        let items: [Item]
        
        var feed: [WorkoutItem] {
            return items.map { $0.item }
        }
    }
    
    private struct Item: Decodable {
        let id: String
        let title: String
        
        var item: WorkoutItem {
            return WorkoutItem(id: id, title: title)
        }
    }
    
    static var OK_200: Int { return 200 }
    
    static func map(_ data: Data, from response: HTTPURLResponse) throws -> [WorkoutItem] {
        guard response.statusCode == OK_200 else {
            throw RemoteWorkoutLoader.Error.invalidData
        }
        
        let root = try JSONDecoder().decode(Root.self, from: data)

        return root.feed
    }
}
