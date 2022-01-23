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
    
    // MARK: - Callbacks
        ///timer callbacks
    var updateMainTimerClosure:((Int)->())?
    var updateMinuteTimerClosure:((Int)->())?
    var minuteTimerFinished:(()->())?
    var mainTimerCompleted:(()->())?
    var minuteCompleted:(()->())?
        ///database callbacks
    var rpeScoreUploaded:(()->())?
    
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
    var apiService: EMOMFirebaseServiceProtocol!
    
    // MARK: - Initializer
    init(apiService: EMOMFirebaseServiceProtocol = EMOMFirebaseService.shared) {
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

    }
    func emomCompleted() {
        // TODO: - Update Firebase completed = true
        apiService.completedEMOM(on: workout, at: position) { [weak self] result in
            guard let self = self else {return}
            switch result {
            case .success(()):
                self.successfullyCompletedEMOM = true
            case .failure(let error):
                self.errorCompleting = error
            }
        }
    }
    func rpeScoreGiven(_ score: Int) {
        // TODO: - Update Firebase and return when completed
        apiService.uploadRPEScore(on: workout, at: position, with: score) { [weak self] result in
            guard let self = self else {return}
            switch result {
            case .success(()):
                self.successfullyUploadedRPEScore = true
            case .failure(let error):
                self.errorUploadingScore = error
            }
        }
    }
}
