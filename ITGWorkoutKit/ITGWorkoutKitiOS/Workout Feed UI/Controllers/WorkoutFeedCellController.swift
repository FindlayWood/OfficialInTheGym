//
//  WorkoutFeedCellController.swift
//  ITGWorkoutKitiOS
//
//  Created by Findlay Wood on 14/07/2024.
//

import UIKit
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
        let cell: WorkoutFeedCell = tableView.dequeueReusableCell()
        
        cell.configure(with: model)
        
        return cell
    }
}
