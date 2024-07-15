//
//  WorkoutFeedCell.swift
//  ITGWorkoutKitiOS
//
//  Created by Findlay Wood on 15/07/2024.
//

import UIKit
import SwiftUI
import ITGWorkoutKit

public final class WorkoutFeedCell: UITableViewCell {
    public var view: WorkoutFeedCellView?
    
    func configure(with model: WorkoutFeedItemViewModel) {
        let content = WorkoutFeedCellView(model: model)
        self.view = content
        self.contentConfiguration = UIHostingConfiguration {
            self.view
        }
    }
}
