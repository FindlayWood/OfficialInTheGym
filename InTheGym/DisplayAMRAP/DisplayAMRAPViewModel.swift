//
//  DisplayAMRAPViewModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 08/06/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation

class DisplayAMRAPViewModel {
    
    // MARK: - Properties
    var amrapModel: AMRAPModel!
    var workoutModel: WorkoutModel!
    
    // MARK: - Callbacks
    var updateTimeLabelHandler: ((Int)->())?
    var updateRoundsLabelHandler: ((Int)->())?
    var updateExercisesLabelHandler: ((Int)->())?
    var updateCurrentExercise: ((ExerciseModel)->())?
    var updateTimeLabelToRedHandler: (()->())?
    var timerCompleted: (()->())?
    var connectionError: (()->())?
    
    // MARK: - Properties
    
    var timer = Timer()
    var isTimerRunning = false
    var seconds: Int!
    var apiService: FirebaseDatabaseManagerService
    
    // MARK: - Initializer
    init(apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared) {
        self.apiService = apiService
    }
    

    // MARK: - Start AMRAP
    func start() {
        // TODO: - Start the timer
        amrapModel.started = true
        startTimer()
    }


    // MARK: - Timer
    func startTimer() {
        seconds = amrapModel.timeLimit
        updateTimeLabelHandler?(seconds)
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)

    }
    @objc func updateTimer() {
        if seconds > 0 {
            seconds -= 1
            updateTimeLabelHandler?(seconds)
        } else {
            timer.invalidate()
            timerCompleted?()
            amrapCompleted()
        }
    }
    
    // MARK: - Complete Exercise
    func exerciseCompleted() {
        amrapModel.exercisesCompleted += 1
        updateExercisesLabelHandler?(amrapModel.exercisesCompleted)
        updateCurrentExercise?(getCurrentExercise())
        updateDataBase(with: .exercises)
        if amrapModel.exercisesCompleted % amrapModel.exercises.count == 0 {
            amrapModel.roundsCompleted += 1
            updateRoundsLabelHandler?(amrapModel.roundsCompleted)
            updateDataBase(with: .rounds)
        }
    }
    // MARK: - AMRAP Completed
    func amrapCompleted() {
        amrapModel.completed = true
        updateDataBase(with: .completed)
    }
    func rpeScoreGiven(_ score: Int) {
        let updateModel = AMRAPUpdateModel(workout: workoutModel, amrap: amrapModel, type: .rpe(score))
        let uploadPoint = updateModel.uploadModel()
        apiService.multiLocationUpload(data: [uploadPoint]) { [weak self] result in
            guard let self = self else {return}
            switch result {
            case .success(()):
                break
            case .failure(_):
                self.connectionError?()
            }
        }
    }
    
    // MARK: - API Database Updates
    func updateDataBase(with type: AMRAPUpdateType) {
        let updateModel = AMRAPUpdateModel(workout: workoutModel, amrap: amrapModel, type: type)
        let uploadModel = updateModel.uploadModel()
        apiService.multiLocationUpload(data: [uploadModel]) { [weak self] result in
            guard let self = self else {return}
            switch result {
            case .success(()): break
            case .failure(_):
                //TODO: - Show connection error message
                break
            }
        }
    }


    // MARK: - Retreiving Functions
    func getProgress(for newTime: Int) -> Double {
        let fullTime = amrapModel.timeLimit
        let progress = Double(Double(newTime) / Double(fullTime))
        return progress
    }
    func getCurrentExercise() -> ExerciseModel {
        return amrapModel.getCurrentExercise()
    }
    func isStartButtonEnabled() -> Bool {
        if workoutModel.startTime != nil && !workoutModel.completed {
            return true
        } else {
            return false
        }
    }
    func isDoneButtonEnabled() -> Bool {
        if amrapModel.started && !amrapModel.completed {
            return true
        } else {
            return false
        }
    }
    func getExercises(at indexPath: IndexPath) -> ExerciseModel {
        let exercises = amrapModel.exercises
        let position = indexPath.item % exercises.count
        return exercises[position]
    }
    func numberOfExercises() -> Int {
        let exercises = amrapModel.exercises
        return exercises.count
    }
}
