//
//  Programs.swift
//  InTheGym
//
//  Created by Findlay Wood on 20/02/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation

// MARK: - Program
/// Program Model
/// Programs contain array of weeks which contain array of workouts
class ProgramModel: Codable, Hashable {
    var id: String
    var title: String
    var weeks: [ProgramWeekModel]
    var creatorID: String
    var isPrivate: Bool

    static func == (lhs: ProgramModel, rhs: ProgramModel) -> Bool {
        lhs.id == rhs.id
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
extension ProgramModel: FirebaseInstance {
    var internalPath: String {
        return "Programs/\(UserDefaults.currentUser.uid)/\(id)"
    }
}


// MARK: - Saved Programs
/// Saved Programs Model
/// Stored in the database for re use
class SavedProgramModel: Codable, Hashable {
    var id: String
    var title: String
    var description: String
    var weeks: [ProgramWeekModel]
    var creatorID: String
    var isPrivate: Bool
    var downloads: Int
    var numberOfCompletions: Int
    /*
     In the future programs will have a price for the ability to sell
     var price: Double
     */
    
    init(createdModel: CreateProgramModel) {
        self.id = UUID().uuidString /// time ordered id first needs UUID().uuidString to compile
        self.title = createdModel.title
        self.description = createdModel.description
        self.weeks = createdModel.weeks.map { ProgramWeekModel(createdWeek: $0) }
        self.creatorID = UserDefaults.currentUser.uid
        self.isPrivate = createdModel.isPrivate
        self.downloads = 0
        self.numberOfCompletions = 0
    }
    
    static func == (lhs: SavedProgramModel, rhs: SavedProgramModel) -> Bool {
        lhs.id == rhs.id
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
extension SavedProgramModel: FirebaseModel {
    static var path: String {
        return "SavedPrograms"
    }
}
extension SavedProgramModel: FirebaseTimeOrderedModel {
    var internalPath: String {
        return "SavedPrograms"
    }
}

struct CreateProgramModel {
    var title: String = ""
    var description: String = ""
    var weeks: [CreateProgramWeekModel] = [CreateProgramWeekModel.firstWeek]
    var isPrivate: Bool = false
}
struct CreateProgramWeekModel {
    var weekNumber: Int
    var workouts: [ProgramCreationWorkoutCellModel]
    
    func getWorkoutModels() -> [WorkoutModel] {
        return workouts.map { WorkoutModel(savedModel: $0.savedWorkout, assignTo: UserDefaults.currentUser.uid)}
    }
}
extension CreateProgramWeekModel {
    static var firstWeek = CreateProgramWeekModel(weekNumber: 1, workouts: [])
}

// MARK: - Program Week
/// A program week model
/// Contains an array of workouts and week number
/// A program has array of weeks
struct ProgramWeekModel: Codable {
    var weekNumber: Int
    var workouts: [WorkoutModel]
    
    init(createdWeek: CreateProgramWeekModel) {
        self.weekNumber = createdWeek.weekNumber
        self.workouts = createdWeek.getWorkoutModels()
    }
}

// MARK: - My Programs Reference Model
/// Program to upload and download a program reference
struct MyProgramReferenceModel {
    var id: String
    
    func getUploadPoints() -> [FirebaseMultiUploadDataPoint] {
        return [FirebaseMultiUploadDataPoint(value: true, path: internalPath)]
    }
}
extension MyProgramReferenceModel: FirebaseInstance {
    var internalPath: String {
        return "MyPrograms/\(UserDefaults.currentUser.uid)/\(id)"
    }
}
// MARK: - My Programs Download Model
struct MyProgramsDownloadModel: FirebaseInstance {
    var internalPath: String {
        return "MyPrograms/\(UserDefaults.currentUser.uid)"
    }
}

// MARK: - Saved Program Download Model
struct SavedProgramDownloadModel {
    var id: String
}
extension SavedProgramDownloadModel: FirebaseInstance {
    var internalPath: String {
        return "SavedPrograms/\(id)"
    }
}


// MARK: - Current Program Model
struct CurrentProgramModel {
    var id: String
    var savedID: String
    var title: String
    var description: String
    var weeks: [ProgramWeekModel]
    var creatorID: String
    var isPrivate: Bool
    
    init(_ savedProgramModel: SavedProgramModel) {
        self.id = "CurrentProgram"
        self.savedID = savedProgramModel.id
        self.title = savedProgramModel.title
        self.description = savedProgramModel.description
        self.weeks = savedProgramModel.weeks
        self.creatorID = savedProgramModel.creatorID
        self.isPrivate = savedProgramModel.isPrivate
    }
}
extension CurrentProgramModel: FirebaseInstance {
    var internalPath: String {
        return "CurrentProgram/\(UserDefaults.currentUser.uid)/\(id)"
    }
}
