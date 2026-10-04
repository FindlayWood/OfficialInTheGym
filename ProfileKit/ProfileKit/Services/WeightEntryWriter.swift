//
//  WeightEntryWriter.swift
//  ProfileKit
//
//  Created by Findlay Wood on 03/10/2026.
//
import Foundation

/// Writes one day's weight entry, replacing any entry already on that day.
public protocol WeightEntryWriter {
    func log(_ entry: WeightEntry) async throws
}
