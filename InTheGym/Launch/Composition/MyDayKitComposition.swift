//
//  MyDayKitComposition.swift
//  InTheGym
//
//  Created by Findlay Wood on 05/08/2025.
//  Copyright © 2025 FindlayWood. All rights reserved.
//

import UIKit
import MyDayKit
import SwiftUI

class MyDayKitComposition {
    
    func compose() -> UIHostingController<MyDayKitRootview> {
        let loader: ExerciseLoader = FirebaseExerciseLoader()
        let mainThreadLoader: ExerciseLoader = MainThreadExerciseLoaderDecorator(decoratee: loader)
        let exerciseManager = ExerciseManager(loader: mainThreadLoader)
        let dayManager = MyDayManager()
        
        let router = MyDayKitRouter(exerciseManager: exerciseManager, dayManager: dayManager)
        let view = MyDayKitRootview(router: router)
        let hostingController = UIHostingController(rootView: view)
        return hostingController
    }
}

class MainThreadExerciseLoaderDecorator: ExerciseLoader {
    let decoratee: ExerciseLoader
    
    init(decoratee: ExerciseLoader) {
        self.decoratee = decoratee
    }
    
    func loadAll() async throws -> [Exercise] {
        let exercises = try await decoratee.loadAll()
        return await MainActor.run { exercises }
    }
}

class FirebaseExerciseLoader: ExerciseLoader {
    
    let firestoreService: FirestoreService
    
    init(firestoreService: FirestoreService = FirestoreManager.shared) {
        self.firestoreService = firestoreService
    }
    
    func loadAll() async throws -> [Exercise] {
        return try await firestoreService.readAll(at: "Exercises")
    }
}
