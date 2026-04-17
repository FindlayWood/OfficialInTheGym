//
//  WellnessPolicyLoader.swift
//  InTheGym
//
//  Created by Findlay Wood on 16/04/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//

import Foundation
import MyDayKit

struct WellnessPolicyLoader: WellnessLoader {
    let localLoader: WellnessLoader
    let remoteLoader: WellnessLoader
    let policy: MyDayLoaderPolicy
    
    init(
        localLoader: WellnessLoader,
        remoteLoader: WellnessLoader,
        policy: MyDayLoaderPolicy
    ) {
        self.localLoader = localLoader
        self.remoteLoader = remoteLoader
        self.policy = policy
    }
    
    func load<T: Codable>(for date: Date) async throws -> T? {
        if isWithinPolicyLimit(date) {
            try await localLoader.load(for: date)
        } else {
            try await remoteLoader.load(for: date)
        }
    }
    
    func isWithinPolicyLimit(_ date: Date) -> Bool {
        let calendar = Calendar.current
        let now = Date()
        
        // Start of today
        let startOfToday = calendar.startOfDay(for: now)
        
        // Start of the day 7 days ago
        guard let sevenDaysAgo = calendar.date(byAdding: .day, value: -policy.dayLimit, to: startOfToday) else { return false }
        
        return date >= sevenDaysAgo && date <= now
    }
}
