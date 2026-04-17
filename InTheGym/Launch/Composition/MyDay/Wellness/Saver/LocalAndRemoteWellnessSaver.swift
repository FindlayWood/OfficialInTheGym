//
//  LocalAndRemoteWellnessSaver.swift
//  InTheGym
//
//  Created by Findlay Wood on 16/04/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//

import Foundation
import MyDayKit

class LocalAndRemoteWellnessSaver: WellnessSaver {
    let local: WellnessSaver
    let remote: WellnessSaver
    
    init(local: WellnessSaver, remote: WellnessSaver) {
        self.local = local
        self.remote = remote
    }
    
    func save<T: Codable>(data: T) async throws {
        try await local.save(data: data)
        try await remote.save(data: data)
    }
}
