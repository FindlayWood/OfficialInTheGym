//
//  JournalEntryWriter.swift
//  PerformanceKit
//
//  Created by Findlay Wood on 10/10/2026.
//
import Foundation

/// Saves a new journal entry. Where it lands, and how many places, is the
/// composition root's business: today an entry is written twice, once into the
/// journal and once as the latest entry, by two writers behind one decorator.
public protocol JournalEntryWriter {
    func write(_ entry: JournalEntry) async throws
}
