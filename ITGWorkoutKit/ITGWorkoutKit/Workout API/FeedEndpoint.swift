//
//  FeedEndpoint.swift
//  ITGWorkoutKit
//
//  Created by Findlay Wood on 13/07/2024.
//

import Foundation

public enum FeedEndpoint {
    case get

    public func url(baseURL: URL) -> URL {
        switch self {
        case .get:
            return baseURL.appendingPathComponent("/v1/feed")
        }
    }
}
