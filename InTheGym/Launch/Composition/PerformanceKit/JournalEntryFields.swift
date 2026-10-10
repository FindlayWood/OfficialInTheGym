//
//  JournalEntryFields.swift
//  InTheGym
//
//  Created by Findlay Wood on 10/10/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//
import Foundation
import PerformanceKit

/// The fields of a journal document. **Both writers use this**, so the entry
/// and the latest-entry copy cannot drift apart, and the loader reads the same
/// two keys back. The id is the document's, not a field.
enum JournalEntryFields {

    static func fields(of entry: JournalEntry) -> [String: Any] {
        ["date": entry.date, "entry": entry.entry]
    }
}
