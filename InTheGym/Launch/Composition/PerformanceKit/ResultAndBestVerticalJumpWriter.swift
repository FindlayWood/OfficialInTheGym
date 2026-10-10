//
//  ResultAndBestVerticalJumpWriter.swift
//  InTheGym
//
//  Created by Findlay Wood on 10/10/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//
import PerformanceKit

/// Saves a jump into the history, then updates the best. It knows no paths:
/// each writer it wraps knows one.
///
/// The legacy view model wrote both in one `WriteBatch`, the shape
/// *Composition root mechanics* rules out. The history is the record, so it
/// goes first, and a failure there writes nothing else. A failure on the second
/// write leaves the jump in the history with a best that does not count it,
/// and the screen offers the save again. A retry adds the jump to the history
/// a second time, since each result gets a new document id, as it always has.
struct ResultAndBestVerticalJumpWriter: VerticalJumpWriter {

    let result: VerticalJumpWriter
    let best: VerticalJumpWriter

    func write(_ save: VerticalJumpSave) async throws {
        try await result.write(save)
        try await best.write(save)
    }
}
