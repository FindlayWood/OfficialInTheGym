//
//  WorkoutExerciseBuilderManager.swift
//  MyDayKit
//
//  Created by Findlay Wood on 04/06/2026.
//

import Foundation

class WorkoutExerciseBuilderManager: ObservableObject, Hashable {
    static func == (lhs: WorkoutExerciseBuilderManager, rhs: WorkoutExerciseBuilderManager) -> Bool {
        lhs === rhs
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
    
    @Published var sets: [WorkoutExerciseSetManager] = []
    
    let exercise: Exercise
    
    init(exercise: Exercise) {
        self.exercise = exercise
    }
    
    func addSets(_ number: Int) {
        sets = (0..<number).map { _ in WorkoutExerciseSetManager() }
    }
}
