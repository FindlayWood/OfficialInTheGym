//
//  LocalWellnessLoader.swift
//  InTheGym
//
//  Created by Findlay Wood on 16/04/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//

import Foundation
import MyDayKit

class FileManagerWellnessLoader: WellnessLoader {
    
    private let policy: MyDayLoaderPolicy
    
    init(policy: MyDayLoaderPolicy) {
        self.policy = policy
    }
    
    private var baseURL: URL {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let dir = docs.appendingPathComponent("Wellness", isDirectory: true)
        
        if !FileManager.default.fileExists(atPath: dir.path) {
            try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        }
        return dir
    }
    
    private func fileURL(for date: Date) -> URL {
        let userID = UserDefaults.currentUser.uid

        // Per-user directory
        let userDir = baseURL.appendingPathComponent(userID, isDirectory: true)
        if !FileManager.default.fileExists(atPath: userDir.path) {
            try? FileManager.default.createDirectory(at: userDir, withIntermediateDirectories: true)
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let filename = formatter.string(from: date) + ".json"
        
        return userDir.appendingPathComponent(filename)
    }
    
    func load<T: Codable>(for date: Date) async throws -> T? {
        deleteOldDays()
        do {
            let url = fileURL(for: date)
            guard FileManager.default.fileExists(atPath: url.path) else {
                return nil
            }
            let data = try Data(contentsOf: url)
            let day = try JSONDecoder().decode(T.self, from: data)
            return day
        } catch {
            print("❌ Error loading day: \(error)")
            return nil
        }
    }
}

extension  FileManagerWellnessLoader {
    
    /// Returns the folder for the current user
    private var userFolder: URL {
        let userID = UserDefaults.currentUser.uid
        let folder = baseURL.appendingPathComponent(userID, isDirectory: true)
        if !FileManager.default.fileExists(atPath: folder.path) {
            try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        }
        return folder
    }
    
    /// Loads all file URLs for the current user
    private func allDayFiles() -> [URL] {
        do {
            let urls = try FileManager.default.contentsOfDirectory(at: userFolder, includingPropertiesForKeys: nil)
            return urls.filter { $0.pathExtension == "json" }
        } catch {
            print("❌ Error listing files: \(error)")
            return []
        }
    }
    
    /// Deletes files older than 7 days
    func deleteOldDays() {
        let calendar = Calendar.current
        let now = Date()
        let timescale = policy.dayLimit + 1 // this is so the same day is not deleted
        guard let sevenDaysAgo = calendar.date(byAdding: .day, value: -timescale, to: now) else { return }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        for file in allDayFiles() {
            let filename = file.deletingPathExtension().lastPathComponent
            if let fileDate = formatter.date(from: filename), fileDate < sevenDaysAgo {
                try? FileManager.default.removeItem(at: file)
                print("🗑 Deleted old wellness file: \(filename)")
            }
        }
    }
}
