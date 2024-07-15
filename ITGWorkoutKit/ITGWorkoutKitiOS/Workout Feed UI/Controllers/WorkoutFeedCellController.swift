//
//  WorkoutFeedCellController.swift
//  ITGWorkoutKitiOS
//
//  Created by Findlay Wood on 14/07/2024.
//

import UIKit
import SwiftUI
import ITGWorkoutKit

public class WorkoutFeedCellController: NSObject, UITableViewDataSource {
    private let model: WorkoutFeedItemViewModel

    public init(model: WorkoutFeedItemViewModel) {
        self.model = model
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell()
        
        tableView.separatorStyle = .none
        
        cell.contentConfiguration = UIHostingConfiguration {
            WorkoutFeedCellView(model: model)
        }
        
        return cell
    }
}
