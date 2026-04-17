//
//  LocalWithRemoteFallBackWellnessLoader.swift
//  InTheGym
//
//  Created by Findlay Wood on 16/04/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//

import Foundation
import MyDayKit

struct LocalWithRemoteFallBackWellnessLoader: WellnessLoader {
    let localLoader: WellnessLoader
    let remoteLoader: WellnessLoader
    
    func load<T: Codable>(for date: Date) async throws -> T? {
        if let data: T = try? await localLoader.load(for: date) {
            return data
        } else {
            return try await remoteLoader.load(for: date)
        }
    }
}
