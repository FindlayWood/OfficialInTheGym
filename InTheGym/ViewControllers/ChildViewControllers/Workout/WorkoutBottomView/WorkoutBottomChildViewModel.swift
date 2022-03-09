//
//  WorkoutBottomChildViewModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 08/03/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
import UIKit

class WorkoutBottomChildViewModel {
    
    // MARK: - Publishers
    
    // MARK: - Frame
    let screen = UIScreen.main.bounds
    let beginningHeight = Constants.screenSize.height * 0.25
    let secondHeight = Constants.screenSize.height * 0.6
    lazy var beginningFrame = CGRect(x: 0, y: screen.height - beginningHeight, width: screen.width, height: beginningHeight)
    lazy var secondFrame = CGRect(x: 0, y: screen.height - secondHeight, width: screen.width, height: secondHeight)
    lazy var fullFrame = CGRect(x: 0, y: 0, width: screen.width, height: screen.height)
    
    
    // MARK: - Properties
    var workoutModel: WorkoutModel!
    
    var bottomViewStage: WorkoutBottomViewStage = .first
    
    var apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared
    
    // MARK: - Initializer
    init(apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared) {
        self.apiService = apiService
    }
    
    // MARK: - Actions
    func startWorkout() {
        workoutModel.startTime = Date().timeIntervalSince1970
        let timeUploadPoint = workoutModel.getTimeUpdatePoint()
        apiService.multiLocationUpload(data: [timeUploadPoint]) { result in
            switch result {
            case .success(()):
                break
            case .failure(let error):
                print(String(describing: error))
                break
            }
        }
        
    }
    
    // MARK: - Functions
}

enum WorkoutBottomViewStage {
    case first
    case second
    case third(String)
}
