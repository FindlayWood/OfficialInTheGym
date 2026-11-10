//
//  InjuryUploading.swift
//  MyDayKit
//
//  Created by Findlay Wood on 10/11/2026.
//

import Foundation

/// Writes one injury somewhere — `ScheduleUploading`'s shape. The local file, the Firestore
/// path, the sync queue and the decorators composing them all conform, so the composition root
/// can wrap one in another.
///
/// **Adding, checking in, clearing and removing are all this one call.** An injury is written
/// whole, its check-ins with it, so there is no separate delete for two copies to disagree over.
public protocol InjuryUploading {
    func upload(_ injury: Injury) async throws
}
