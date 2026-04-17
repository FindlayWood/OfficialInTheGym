//
//  WellnessFileManagerSaver.swift
//  InTheGym
//
//  Created by Findlay Wood on 16/04/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//

import Foundation
import MyDayKit

final class WellnessFileManagerSaver: WellnessSaver {
    private let baseURL: URL

    init() {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let dir = docs.appendingPathComponent("Wellness", isDirectory: true)

        if !FileManager.default.fileExists(atPath: dir.path) {
            try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        }

        self.baseURL = dir
    }
    
    private func fileURL() -> URL {
        let userID = UserDefaults.currentUser.uid

        // Per-user directory
        let userDir = baseURL.appendingPathComponent(userID, isDirectory: true)
        if !FileManager.default.fileExists(atPath: userDir.path) {
            try? FileManager.default.createDirectory(at: userDir, withIntermediateDirectories: true)
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let filename = formatter.string(from: Date.now) + ".json"
        
        return userDir.appendingPathComponent(filename)
    }

    func save<T: Codable>(data: T) async throws {
        let url = fileURL()
        let encoded = try JSONEncoder().encode(data)
        try encoded.write(to: url, options: [.atomic])
    }
}
