//
//  DisplayWorkoutStatsViewModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 24/06/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import UIKit

class DisplayWorkoutStatsViewModel {
    
    var reloadCollectionViewClosure: (() -> ())?
    var updateLoadingStatusClosure: (() -> ())?
    
    var firebaseService: FirebaseAPILoader!
    var workoutSavedID: String!
    
    let images: [UIImage] = [UIImage(named: "eye_icon")!, UIImage(named: "download_icon")!, UIImage(named: "clock_icon")!, UIImage(named: "scores_icon")!, UIImage(named: "Workout Completed")!]
    let titles = ["Views", "Downloads", "Average Time", "Average Score", "Completions"]
    
    var stats: WorkoutStatsModel! {
        didSet {
            self.reloadCollectionViewClosure?()
        }
    }
    
    var numberOfItems: Int {
        if stats != nil {
            return 5
        } else {
            return 0
        }
    }
    
    var isLoading: Bool = false {
        didSet {
            self.updateLoadingStatusClosure?()
        }
    }
    
    init(workoutSavedID: String, firebaseService: FirebaseAPILoader) {
        self.workoutSavedID = workoutSavedID
        self.firebaseService = firebaseService
    }
    
    
    func fetchData() {
        self.isLoading = true
        firebaseService.loadWorkoutStats(with: workoutSavedID) { [weak self] result in
            guard let self = self else {return}
            switch result{
            case .failure(let error):
                print(error.localizedDescription)
                self.isLoading = false
            case .success(let model):
                self.stats = model
                self.isLoading = false
            }
        }
    }
    
    
    func getData(at indexPath: IndexPath) -> WorkoutStatCellModel {
        let image = images[indexPath.item]
        let title = titles[indexPath.item]
        var stat: String!
        switch title{
        case "Views":
            stat = stats.numberOfView.description
        case "Downloads":
            stat = stats.numberOfDownloads.description
        case "Average Time":
            let formatter = DateComponentsFormatter()
            
            if stats.averageTimeToComplete > 3600{
                formatter.allowedUnits = [.hour, .minute]
                formatter.unitsStyle = .abbreviated
            }else{
                formatter.allowedUnits = [.minute, .second]
                formatter.unitsStyle = .abbreviated
            }
            
            let timeString = formatter.string(from: TimeInterval(stats.averageTimeToComplete))
            stat = timeString
        case "Average Score":
            stat = stats.averageRPEScore.description
        case "Completions":
            stat = stats.numberOfCompletes.description
        default:
            stat = stats.numberOfView.description
        }
        return WorkoutStatCellModel(image: image, title: title, stat: stat)
    }
    
}
