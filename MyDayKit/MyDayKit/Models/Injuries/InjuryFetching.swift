//
//  InjuryFetching.swift
//  MyDayKit
//
//  Created by Findlay Wood on 10/11/2026.
//

import Foundation

/// Reads the signed-in user's injuries from one store, the local files or their Firestore copy.
/// `InjuryManager` reads both and merges them (`Injury.merged`).
public protocol InjuryFetching {
    func fetchAll() async throws -> [Injury]
}
