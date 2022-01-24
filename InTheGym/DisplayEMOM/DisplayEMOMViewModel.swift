//
//  DisplayEMOMViewModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 20/09/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation

class DisplayEMOMViewModel {
    
    // MARK: - Properties
    var emomModel: EMOMModel!
    
    var workoutModel: WorkoutModel!
    
    var exerciseIndex: Int = 0
    
    // MARK: - Callbacks
        ///timer callbacks
    var updateMainTimerClosure:((Int)->())?
    var updateMinuteTimerClosure:((Int)->())?
    var minuteTimerFinished:(()->())?
    var mainTimerCompleted:(()->())?
    var minuteCompleted:(()->())?
        ///database callbacks
    var rpeScoreUploaded:(()->())?
    var connectionError:(()->())?
    
    var exerciseToShow:((ExerciseModel)->())?
    
    // MARK: - Testing Variables
    var successfullyStartedEMOM: Bool = false
    var successfullyCompletedEMOM: Bool = false
    var successfullyUploadedRPEScore: Bool = false
    var errorStarting: Error?
    var errorCompleting: Error?
    var errorUploadingScore: Error?
    
    // MARK: - Timers
    var mainTimer = Timer()
    
    // MARK: - Timer Variables
    var minuteTimerVariable = 60
    var mainTimerVariable = 600
    
    // MARK: - Properties
    var workout: workout!
    var position: Int!
    
    // MARK: - API Service
    var apiService: FirebaseDatabaseManagerService
    
    // MARK: - Initializer
    init(apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared) {
        self.apiService = apiService
    }
    
    // MARK: - Functions
    func startTimers() {
        updateMainTimerClosure?(mainTimerVariable)
        updateMinuteTimerClosure?(minuteTimerVariable)
        mainTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateMainTimer), userInfo: nil, repeats: true)
    }
    
    @objc func updateMainTimer() {
        if mainTimerVariable > 0 {
            mainTimerVariable -= 1
            updateMainTimerClosure?(mainTimerVariable)
        } else {
            mainTimer.invalidate()
            mainTimerCompleted?()
        }
        if minuteTimerVariable > 0 {
            minuteTimerVariable -= 1
            updateMinuteTimerClosure?(minuteTimerVariable)
        } else if minuteTimerVariable == 0 {
            minuteTimerVariable = 59
            updateMinuteTimerClosure?(minuteTimerVariable)
            minuteCompleted?()
        }
    }
    
    // MARK: - Starting EMOM
    func startEMOM() {
        // TODO: - Update Firebase started = true
        startTimers()
        emomModel.started = true

    }
    func completedMinute() {
        let numberOfExercises = emomModel.exercises.count
        let exercises = emomModel.exercises
        let completedPosition = exerciseIndex % numberOfExercises
        let exerciseName = exercises[completedPosition].exercise
        let exerciseReps = exercises[completedPosition].reps[0]
        exerciseIndex += 1
        let position = exerciseIndex % numberOfExercises
        exerciseToShow?(exercises[position])
    }
    func emomCompleted() {
        // TODO: - Update Firebase completed = true
        let uploadModel = EMOMUpdateModel(workout: workoutModel, emom: emomModel, type: .completed)
        let uploadPoint = uploadModel.uploadModel()
        apiService.multiLocationUpload(data: [uploadPoint]) { [weak self] result in
            guard let self = self else {return}
            switch result {
            case .success(()):
                break
            case .failure(_):
                //TODO: - Show connection error message
                break
            }
        }
    }
    func rpeScoreGiven(_ score: Int) {
        // TODO: - Update Firebase and return when completed
        let uploadModel = EMOMUpdateModel(workout: workoutModel, emom: emomModel, type: .rpe(score))
        let uploadPoint = uploadModel.uploadModel()
        apiService.multiLocationUpload(data: [uploadPoint]) { [weak self] result in
            guard let self = self else {return}
            switch result {
            case .success(()):
                break
            case .failure(_):
                // TODO: - Show Connection Error Message
                break
            }
        }
    }
}
