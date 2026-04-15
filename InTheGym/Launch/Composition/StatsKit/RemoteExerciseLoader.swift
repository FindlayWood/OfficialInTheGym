//
//  RemoteExerciseLoader.swift
//  InTheGym
//
//  Created by Findlay Wood on 04/04/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//

import FirebaseFirestore
import Foundation
import StatsKit

class RemoteExerciseLoader: ExerciseLoader {
    private let db = Firestore.firestore()
    
    func loadAll() async throws -> [Exercise] {
        let path = "Exercises"
        
        let snapshot = try await db.collection(path).getDocuments()
        
        return snapshot.documents.compactMap { document in
            try? document.data(as: Exercise.self)
        }
    }
}
