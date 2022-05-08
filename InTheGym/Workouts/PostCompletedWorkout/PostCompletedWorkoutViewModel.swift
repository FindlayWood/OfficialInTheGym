//
//  PostCompletedWorkoutViewModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 08/05/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
import Combine

class PostCompletedWorkoutViewModel {
    
    // MARK: - Publishers
    var postWorkoutSelected = PassthroughSubject<Void,Never>()
    
    var dismissSelected = PassthroughSubject<Void,Never>()
    
    // MARK: - Properties
    /// the workout that has just been completed
    var workoutModel: WorkoutModel!
    
    /// is the workout private
    var isPrivate: Bool {
        workoutModel.isPrivate
    }
    
    /// can post clips
    var canPostClips: Bool {
        false
//        UserDefaults.currentUser.premiumAccount ?? false && !(workoutModel.clipData?.isEmpty ?? true)
    }
    
    /// can post the workout summary
    var canPostSummary: Bool {
        false
//        UserDefaults.currentUser.premiumAccount ?? false && workoutModel.summary != nil
    }
    
    var apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared
    
    // MARK: - Initializer
    init(apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared) {
        self.apiService = apiService
    }
    
    // MARK: - Actions
    func postWorkout() {
        
    }
    func postClips() {
        
    }
    func postSummary() {
        
    }
    
    // MARK: - Functions
}
