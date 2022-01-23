//
//  DisplayAMRAPViewModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 08/06/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation

@available(iOS 13.0, *)
class DisplayAMRAPViewModel {
    
    // MARK: - Properties
    var amrapModel: AMRAPModel!
    var workoutModel: WorkoutModel!
    
    // MARK: - Callbacks
    var updateTimeLabelHandler: ((String)->())?
    var updateRoundsLabelHandler: ((String)->())?
    var updateExercisesLabelHandler: ((String)->())?
    var updateTimeLabelToRedHandler: (()->())?
    var timerCompleted: (()->())?
    
    // MARK: - Properties
    
    var timer = Timer()
    var isTimerRunning = false
    var seconds: Int!
    var apiService: FirebaseDatabaseManagerService
    
    // MARK: - Initializer
    init(apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared) {
        self.apiService = apiService
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
//    func exerciseCompleted() {
//        guard let started = amrap.started,
//              let completed = amrap.completed.value,
//              var exercisesCompleted = amrap.exercisesCompleted,
//              let exercises = amrap.exercises,
//              let rounds = amrap.roundsCompleted.value
//        else {return}
//        if started && !completed {
//            let exercise = exercises[exercisesCompleted]
//            FirebaseAPIWorkoutManager.shared.checkForExerciseStats(name: exercise.exercise!, reps: exercise.reps!, weight: nil)
//            exercisesCompleted += 1
//            let exercisePosition = exercisesCompleted % exercises.count
//            //display.amrapExerciseView.configure(with: exercises[exercisePosition])
//            //let nextPosition = IndexPath(item: exercisesCompleted % exercises.count, section: 0)
//            //display.collection.scrollToItem(at: nextPosition, at: .centeredHorizontally, animated: true)
//            //amrap.exercisesCompleted = exercisesCompleted
//            //APIService.uploadExercisesCompleted(at: amrapPosition, on: workout)
//            if exercisesCompleted % exercises.count == 0 {
//                amrapModel.roundsCompleted = rounds + 1
//                //APIService.uploadRoundsCompleted(at: amrapPosition, on: workout)
//            }
//        }
//    }


    func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)

    }
    @objc func updateTimer() {
        if seconds < 6 {
            //display.timeLabel.textColor = .red
        } else {
            //display.timeLabel.textColor = Constants.offWhiteColour
        }
        if seconds > 0 {
            seconds -= 1
            //display.timeLabel.text = "\(timeString(time: TimeInterval(seconds)))"
        } else {
            //APIService.completeAMRAP(at: amrapPosition, on: workout)
            amrapModel.completed = true
            timer.invalidate()
            timerCompleted?()
        }
    }
    // MARK: - Start
    func start() {
        // TODO: - Start the timer
        startTimer()
    }

    func isWorkoutInProgress() -> Bool {
        if workoutModel.startTime != nil && !workoutModel.completed {
            return true
        } else {
            return false
        }
    }
    func isWorkoutCompleted() -> Bool {
        return workoutModel.completed
    }
}
