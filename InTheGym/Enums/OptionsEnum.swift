//
//  OptionsEnum.swift
//  InTheGym
//
//  Created by Findlay Wood on 26/02/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit

enum Options: String {
    case workoutDiscovery = "Show Workout Discovery"
    case assign = "Assign"
    case save = "Save"
    case delete = "Remove from Saved"
    case review = "Review"
    case addWorkout = "Add to Workouts"
    case saveWorkout = "Save Workout"
    case viewCreatorProfile = "View Creator Profile"
    case viewWorkoutStats = "View Workout Stats"
    case makeCurrentProgram = "Make Current Program"
    
    var image: UIImage {
        switch self {
        case .workoutDiscovery:
            return UIImage(systemName: "magnifyingglass")!
        case .assign:
            return UIImage(systemName: "arrowshape.turn.up.forward")!
        case .save:
            return UIImage(systemName: "square.and.arrow.down")!
        case .delete:
            return UIImage(systemName: "trash")!
        case .review:
            return UIImage(systemName: "note.text")!
        case .addWorkout:
            return UIImage(systemName: "plus.circle.fill")!
        case .saveWorkout:
            return UIImage(systemName: "square.and.arrow.down")!
        case .viewCreatorProfile:
            return UIImage(systemName: "person.fill")!
        case .viewWorkoutStats:
            return UIImage(systemName: "chart.bar.fill")!
        case .makeCurrentProgram:
            return UIImage(systemName: "book.closed.fill")!
        }
    }
    var imageName: String {
        switch self {
        case .workoutDiscovery:
            return "magnifyingglass"
        case .assign:
            return "arrowshape.turn.up.forward"
        case .save:
            return "square.and.arrow.down"
        case .delete:
            return "trash"
        case .review:
            return "note.text"
        case .addWorkout:
            return "plus.circle.fill"
        case .saveWorkout:
            return "square.and.arrow.down"
        case .viewCreatorProfile:
            return "person.fill"
        case .viewWorkoutStats:
            return "chart.bar.fill"
        case .makeCurrentProgram:
            return "book.closed.fill"
        }
    }
}
