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
    // MARK: - Closures
    var reloadCollectionViewClosure: (() -> ())?
    var updateLoadingStatusClosure: (() -> ())?
    // MARK: - Properties
    var savedWorkoutModel: SavedWorkoutModel!
    let images: [UIImage] = [UIImage(named: "eye_icon")!, UIImage(named: "download_icon")!, UIImage(named: "clock_icon")!, UIImage(named: "scores_icon")!, UIImage(named: "Workout Completed")!]
    let titles = ["Views", "Downloads", "Average Time", "Average Score", "Completions"]
    
    var stats: WorkoutStatsModel! {
        didSet {
            self.reloadCollectionViewClosure?()
        }
    }
    
    var numberOfItems: Int {
        return 5
    }
    
    var isLoading: Bool = false {
        didSet {
            self.updateLoadingStatusClosure?()
        }
    }
    
    func getData(at indexPath: IndexPath) -> WorkoutStatCellModel {
        let image = images[indexPath.item]
        let title = titles[indexPath.item]
        var stat: String!
        switch title {
        case "Views":
            stat = savedWorkoutModel.views.description
        case "Downloads":
            stat = savedWorkoutModel.downloads.description
        case "Average Time":
            stat = savedWorkoutModel.averageTime()
        case "Average Score":
            stat = savedWorkoutModel.averageScore().rounded(toPlaces: 1).description
        case "Completions":
            stat = savedWorkoutModel.completions.description
        default:
            stat = savedWorkoutModel.views.description
        }
        return WorkoutStatCellModel(image: image, title: title, stat: stat)
    }
    
}
