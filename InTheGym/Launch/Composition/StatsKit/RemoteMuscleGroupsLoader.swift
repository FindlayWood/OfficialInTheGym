//
//  RemoteMuscleGroupsLoader.swift
//  InTheGym
//
//  Created by Findlay Wood on 04/04/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//

import FirebaseFirestore
import Foundation
import MyDayKit
import StatsKit

/// The one reader of `MuscleGroups`. StatsKit names them on the training
/// balance screens and MyDayKit offers them on the custom exercise form; each
/// framework declares its own protocol, and this answers both rather than two
/// readers each knowing the path.
class RemoteMuscleGroupsLoader: MuscleGroupsLoader, ExerciseMuscleGroupsLoader {
    private let db = Firestore.firestore()
    
    func loadAll() async throws -> [MuscleGroup] {
        try await documents().compactMap { document in
            try? document.data(as: MuscleGroup.self)
        }
    }

    func loadMuscleGroups() async throws -> [ExerciseMuscleGroup] {
        try await documents().compactMap { document in
            try? document.data(as: ExerciseMuscleGroup.self)
        }
    }

    private func documents() async throws -> [QueryDocumentSnapshot] {
        let path = "MuscleGroups"
        
        return try await db.collection(path).getDocuments().documents
    }
}
