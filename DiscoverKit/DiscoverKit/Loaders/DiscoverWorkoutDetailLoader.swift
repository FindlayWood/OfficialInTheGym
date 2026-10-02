//
//  DiscoverWorkoutDetailLoader.swift
//  DiscoverKit
//
//  Created by Findlay Wood on 02/10/2026.
//

import Foundation

/// A public workout's full contents, read when its page opens.
public protocol DiscoverWorkoutDetailLoader {
    func detail(ofWorkout templateId: String) async throws -> DiscoverWorkoutDetail
}
