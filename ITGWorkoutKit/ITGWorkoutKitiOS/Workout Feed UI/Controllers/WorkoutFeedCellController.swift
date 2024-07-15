//
//  WorkoutFeedCellController.swift
//  ITGWorkoutKitiOS
//
//  Created by Findlay Wood on 14/07/2024.
//

import UIKit
import ITGWorkoutKit

public class WorkoutFeedCellController: NSObject, UITableViewDataSource {
    private let model: ImageCommentViewModel

    public init(model: ImageCommentViewModel) {
        self.model = model
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ImageCommentCell = tableView.dequeueReusableCell()
        cell.messageLabel.text = model.message
        cell.usernameLabel.text = model.username
        cell.dateLabel.text = model.date
        return cell
    }
}
