//
//  JournalEntriesLoader.swift
//  PerformanceKit
//
//  Created by Findlay Wood on 10/10/2026.
//
import Foundation

/// The athlete's journal, **newest first**. The journal is owner-only
/// (`PerformanceTool.isOwnerOnly`), so the athlete is always the person
/// reading it.
public protocol JournalEntriesLoader {
    func loadEntries() async throws -> [JournalEntry]
}
