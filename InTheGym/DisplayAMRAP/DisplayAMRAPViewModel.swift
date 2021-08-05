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
    
    var updateTimeLabelHandler: ((String)->())?
    var updateRoundsLabelHandler: ((String)->())?
    var updateExercisesLabelHandler: ((String)->())?
    var updateTimeLabelToRedHandler: (()->())?
    
    var APIService: AMRAPFirebaseAPIService!
    var amrap: AMRAP!
    var display: DisplayAMRAPView!
    var workout: workout!
    var amrapPosition: Int!
    
    var timer = Timer()
    var isTimerRunning = false
    var seconds: Int!
    
    init(APIService: AMRAPFirebaseAPIService,
         amrap: AMRAP,
         display: DisplayAMRAPView,
         workout: workout,
         position: Int){
        self.APIService = APIService
        self.amrap = amrap
        self.display = display
        self.workout = workout
        self.amrapPosition = position
        setLabels()
    }
    
    func getExercises(at indexPath: IndexPath) -> exercise {
        guard let exercises = amrap.exercises else {return exercise()!}
        let position = indexPath.item % exercises.count
        return exercises[position]
    }
    func numberOfExercises() -> Int {
        guard let exercises = amrap.exercises else {return 0}
        return exercises.count
    }
    func exerciseCompleted() {
        guard let started = amrap.started,
              let completed = amrap.completed.value,
              var exercisesCompleted = amrap.exercisesCompleted,
              let exercises = amrap.exercises,
              let rounds = amrap.roundsCompleted.value
        else {return}
        if started && !completed {
            let exercise = exercises[exercisesCompleted]
            FirebaseAPIWorkoutManager.shared.checkForExerciseStats(name: exercise.exercise!, reps: exercise.reps!, weight: exercise.weight)
            exercisesCompleted += 1
            let nextPosition = IndexPath(item: exercisesCompleted % exercises.count, section: 0)
            display.collection.scrollToItem(at: nextPosition, at: .centeredHorizontally, animated: true)
            amrap.exercisesCompleted = exercisesCompleted
            APIService.uploadExercisesCompleted(at: amrapPosition, on: workout)
            if exercisesCompleted % exercises.count == 0 {
                amrap.roundsCompleted.value = rounds + 1
                APIService.uploadRoundsCompleted(at: amrapPosition, on: workout)
            }
            updateLabels()
        }
    }
    func scrollToBeginningPosition() {
        guard let exercisesCompleted = amrap.exercisesCompleted,
              let exercises = amrap.exercises
        else {return}
        let beginningPosition = IndexPath(item: exercisesCompleted % exercises.count, section: 0)
        display.collection.scrollToItem(at: beginningPosition, at: .centeredHorizontally, animated: true)
    }
    func setup() {
        guard let started = amrap.started,
              let completed = amrap.completed.value,
              let minutes = amrap.timeLimit
        else {return}
        seconds = minutes * 60
        if started && !completed {
            guard let startTimeInterval = amrap.startTime else {return}
            let secondsSinceBegan = Int(startTimeInterval) / 1000
            let currentTime = Int(Date().timeIntervalSince1970)
            let timerValue = currentTime - secondsSinceBegan
            seconds -= timerValue
            display.timeLabel.text = "\(timeString(time: TimeInterval(seconds)))"
            startTimer()
            updateLabels()
        } else if completed {
            seconds = 0
            display.timeLabel.text = "\(timeString(time: TimeInterval(seconds)))"
            updateLabels()
        } else {
            setLabels()
            updateLabels()
        }
    }
    func setLabels() {
        guard let minutes = amrap.timeLimit else {return}
        seconds = minutes * 60
        display.timeLabel.text = "\(timeString(time: TimeInterval(seconds)))"
    }
    func updateLabels() {
        guard let exercisesCompleted = amrap.exercisesCompleted,
              let roundsCompleted = amrap.roundsCompleted.value
        else {return}
        display.roundsNumberLabel.text = roundsCompleted.description
        display.exerciseNumberLabel.text = exercisesCompleted.description
    }
    func isStartButtonEnabled() -> Bool {
        guard let started = amrap.started,
              let completed = amrap.completed.value
        else {return false}
        if started || completed {
            return false
        } else {
            return true
        }
    }
    func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
        guard let started = amrap.started else {return}
        if !started {
            setStartTime()
            amrap.started = true
        }
    }
    @objc func updateTimer() {
        if seconds < 6 {
            display.timeLabel.textColor = .red
        } else {
            display.timeLabel.textColor = Constants.offWhiteColour
        }
        if seconds > 0 {
            seconds -= 1
            display.timeLabel.text = "\(timeString(time: TimeInterval(seconds)))"
        } else {
            APIService.completeAMRAP(at: amrapPosition, on: workout)
            amrap.completed.value = true
            timer.invalidate()
        }
        
    }
    func timeString(time: TimeInterval) -> String {
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        
        return String(format: "%02i:%02i", minutes, seconds)
    }
    func setStartTime() {
        amrap.startTime = Date().timeIntervalSince1970 * 1000
        APIService.setStartTime(at: amrapPosition, on: workout)
        APIService.startAMRAP(at: amrapPosition, on: workout)
    }
    func isWorkoutInProgress() -> Bool {
        guard let workoutCompleted = workout.completed else{return false}
        if workout.startTime != nil && !workoutCompleted {
            return true
        } else {
            return false
        }
    }
    func isWorkoutCompleted() -> Bool {
        return workout.completed
    }
    func amrapHasStarted() -> Bool {
        guard let started = amrap.started else {return false}
        return started
    }
}
