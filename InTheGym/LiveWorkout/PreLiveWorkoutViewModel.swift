//
//  PreLiveWorkoutViewModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 01/08/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation

class PreLiveWorkoutViewModel {
    
    var apiService: FirebaseAPIWorkoutManager!
    
    private let separator = " - "
    
    var suggestions = ["Session", "Lower Session", "Upper Session", "Mixed Session", "Recovery Session"]
    
    init(apiService: FirebaseAPIWorkoutManager) {
        self.apiService = apiService
    }
    
    var numberOfItems: Int {
        return suggestions.count
    }
    
    func getData(at indexPath: IndexPath) -> String {
        let weekDay = getDay()
        return weekDay + separator + suggestions[indexPath.row]
    }
    
    func getDay() -> String {
        let date = Date()
        return date.getDayOfWeek()
    }
    
    func startLiveWorkout(with title: String, completion: @escaping (liveWorkout?) -> Void) {
        apiService.startLiveWorkout(with: title, completion: completion)
    }
}
