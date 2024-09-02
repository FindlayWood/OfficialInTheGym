//
//  FeedImageViewModel.swift
//  ITGWorkoutKit
//
//  Created by Findlay Wood on 01/05/2024.
//

public struct FeedImageViewModel {
    public let description: String?
    public let location: String?

    public var hasLocation: Bool {
        return location != nil
    }
}
