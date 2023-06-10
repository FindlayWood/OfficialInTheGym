//
//  File.swift
//  
//
//  Created by Findlay-Personal on 22/04/2023.
//

import Foundation

protocol WorkoutModel {
    var id: String { get }
    var title: String { get }
    var exerciseCount: Int { get }
    var completed: Bool { get }
    
}

struct RemoteWorkoutModel: Codable, Identifiable, Equatable {
    var id: String = UUID().uuidString
    var title: String
    var creatorID: String
    var assignedBy: String // the user ID of user who assigned this workout
    var assignedTo: String // the user the workout is assigned to
    var isPrivate: Bool
    var completed: Bool = false
    var exerciseCount: Int
    var addedDate: Date = .now // date workout was added to list
    var exercises: [RemoteExerciseModel] = []
    var savedID: String? // if saved workout then id will link here
    var rpe: Int?
    var startDate: Date? // date workout started
    var endDate: Date? // date workout ended
    var secondsToComplete: Int? // time to complete workout in seconds
    var workload: Int?
    var summary: String?
    var liveWorkout: Bool?
}
extension RemoteWorkoutModel {
    static let example = RemoteWorkoutModel(id: UUID().uuidString, title: "Example", creatorID: "", assignedBy: "", assignedTo: "", isPrivate: false, completed: false, exerciseCount: 3, addedDate: .now)
}

struct WorkoutCardModel: Identifiable {
    var id: String {
        workout.id
    }
    var workout: RemoteWorkoutModel
    var exercises: [RemoteExerciseModel]
//    var clips: [WorkoutClipModel]?
}

class WorkoutController: ObservableObject {
    var id: String
    var title: String
    var savedID: String? // if saved workout then id will link here
    var creatorID: String
    var assignedBy: String // the user ID of user who assigned this workout
    var isPrivate: Bool
    @Published var completed: Bool
    @Published var rpe: Int?
    @Published var startDate: Date?
    @Published var endDate: Date?
    @Published var secondsToComplete: Int? // time to complete workout in seconds
    @Published var workload: Int?
    @Published var summary: String?
    var liveWorkout: Bool?
    
    init(workoutModel: RemoteWorkoutModel) {
        self.id = workoutModel.id
        self.title = workoutModel.title
        self.savedID = workoutModel.savedID
        self.creatorID = workoutModel.creatorID
        self.assignedBy = workoutModel.assignedBy
        self.isPrivate = workoutModel.isPrivate
        self.completed = workoutModel.completed
        self.rpe = workoutModel.rpe
        self.startDate = workoutModel.startDate
        self.endDate = workoutModel.endDate
        self.secondsToComplete = workoutModel.secondsToComplete
        self.workload = workoutModel.workload
        self.summary = workoutModel.summary
        self.liveWorkout = workoutModel.liveWorkout
    }
}

class SetController: ObservableObject, Identifiable {
    var id: String
    var setNumber: Int
    var reps: Int
    @Published var completed: Bool
    var weight: WeightModel?
    var distance: DistanceModel?
    var time: TimeModel?
    var restTime: TimeModel?
    var tempo: TempoModel? = nil
    
    init(setModel: SetModel) {
        self.id = setModel.id
        self.setNumber = setModel.setNumber
        self.reps = setModel.reps
        self.completed = setModel.completed
        self.weight = setModel.weight
        self.distance = setModel.distance
        self.time = setModel.time
        self.restTime = setModel.restTime
        self.tempo = setModel.tempo
    }
}
extension SetController {
    static let example = SetController(setModel: .example)
}
extension SetController: Equatable {
    static func == (lhs: SetController, rhs: SetController) -> Bool {
        lhs.id == rhs.id
    }
}

class ExerciseController: ObservableObject, Identifiable {
    var id: String
    var name: String
    var workoutPosition: Int
    var type: ExerciseType
    @Published var sets: [SetController]
    @Published var rpe: Int?
    @Published var note: String?
    
    init(exerciseModel: RemoteExerciseModel) {
        self.id = exerciseModel.id
        self.name = exerciseModel.name
        self.workoutPosition = exerciseModel.workoutPosition
        self.type = exerciseModel.type
        self.rpe = exerciseModel.rpe
        self.note = exerciseModel.note
        self.sets = exerciseModel.sets.map { SetController(setModel: $0) }
    }
}
extension ExerciseController {
    static let example = ExerciseController(exerciseModel: .example)
}
extension ExerciseController: Equatable {
    static func == (lhs: ExerciseController, rhs: ExerciseController) -> Bool {
        lhs.id == rhs.id
    }
}