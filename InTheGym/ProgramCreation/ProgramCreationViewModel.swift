//
//  ProgramCreationViewModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 20/02/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
import Combine

class ProgramCreationViewModel {
    
    // MARK: - Publishers
    var currentlySelectedWeek = CurrentValueSubject<Int,Never>(1)
    
    var addedNewWeekPublisher = PassthroughSubject<Int,Never>()
    
    var addedNewWorkoutPublisher = PassthroughSubject<ProgramCreationWorkoutCellModel,Never>()
    
    var programChangedPublisher = PassthroughSubject<CreateProgramModel,Never>()
    
    var programCleanedUpPublisher = PassthroughSubject<CreateProgramModel,Never>()
    
    var removedWeek = PassthroughSubject<Int,Never>()
    
    @Published var next: Bool = false
    
    private var subscriptions = Set<AnyCancellable>()
    
    // MARK: - Properties
    var startingProgram: CreateProgramModel = CreateProgramModel()
    
    var isCreating: Bool = false
    
    var apiService: FirebaseDatabaseManagerService
    
    // MARK: - Initializer
    init(apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared) {
        self.apiService = apiService
        initSubscribers()
    }
    
    // MARK: - Subscriptions
    func initSubscribers() {
        programChangedPublisher
            .sink { [unowned self] model in
                let workouts = model.weeks.filter { $0.workouts.count > 0 }
                self.next = workouts.count > 0
            }
            .store(in: &subscriptions)
    }
    
    // MARK: - Functions
    func addNewWeek() {
        let currentNumberOfWeeks = startingProgram.weeks.count
        startingProgram.weeks.append(CreateProgramWeekModel(weekNumber: currentNumberOfWeeks + 1, workouts: startingProgram.weeks[currentNumberOfWeeks - 1].workouts))
        addedNewWeekPublisher.send(startingProgram.weeks.count)
        currentlySelectedWeek.send(startingProgram.weeks.count)
        programChangedPublisher.send(startingProgram)
    }
    
    func removeWeek(with index: Int) {
        startingProgram.weeks.remove(at: index)
        if currentlySelectedWeek.value == index + 1 {
            removedWeek.send(startingProgram.weeks.count)
            currentlySelectedWeek.send(currentlySelectedWeek.value - 1)
        } else if currentlySelectedWeek.value > index + 1 {
            removedWeek.send(startingProgram.weeks.count)
            currentlySelectedWeek.send(currentlySelectedWeek.value - 1)
        }
    }
    
    func addWorkout(_ model: SavedWorkoutModel) {
        let programCreationWorkoutCellModel = ProgramCreationWorkoutCellModel(savedWorkout: model)
        startingProgram.weeks[currentlySelectedWeek.value - 1].workouts.append(programCreationWorkoutCellModel)
        addedNewWorkoutPublisher.send(programCreationWorkoutCellModel)
        programChangedPublisher.send(startingProgram)
    }
    
    func removeWorkout(with index: Int) {
        startingProgram.weeks[currentlySelectedWeek.value - 1].workouts.remove(at: index)
    }
    
    func removeEmptyEndWeeks() {
        if startingProgram.weeks[startingProgram.weeks.count - 1].workouts.isEmpty {
            startingProgram.weeks.remove(at: startingProgram.weeks.count - 1)
            removeEmptyEndWeeks()
        } else {
            programCleanedUpPublisher.send(startingProgram)
        }
    }
    
    
    // MARK: - Retreive Functions
    func getWeeksWorkouts() -> [ProgramCreationWorkoutCellModel] {
        let currentWeek = currentlySelectedWeek.value - 1
        return startingProgram.weeks[currentWeek].workouts
    }
}
