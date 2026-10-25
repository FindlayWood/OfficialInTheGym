//
//  RemoteMovementTypesLoader.swift
//  InTheGym
//
//  Created by Findlay Wood on 13/04/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//

import FirebaseFirestore
import Foundation
import MyDayKit
import StatsKit

/// The one reader of `MovementTypes`, answering StatsKit and MyDayKit — see
/// `RemoteMuscleGroupsLoader`.
class RemoteMovementTypesLoader: MovementTypesLoader, ExerciseMovementPatternsLoader {
    private let db = Firestore.firestore()
    
    func loadAll() async throws -> [MovementPattern] {
        try await documents().compactMap { document in
            try? document.data(as: MovementPattern.self)
        }
    }

    func loadMovementPatterns() async throws -> [ExerciseMovementPattern] {
        try await documents().compactMap { document in
            try? document.data(as: ExerciseMovementPattern.self)
        }
    }

    private func documents() async throws -> [QueryDocumentSnapshot] {
        let path = "MovementTypes"
        
        return try await db.collection(path).getDocuments().documents
    }
}
