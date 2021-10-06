//
//  GroupWorkoutsAdapter.swift
//  InTheGym
//
//  Created by Findlay Wood on 18/08/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import UIKit
import EmptyDataSet_Swift

class GroupWorkoutsAdapter: NSObject {
    var delegate: GroupWorkoutsProtocol
    init(delegate: GroupWorkoutsProtocol) {
        self.delegate = delegate
    }
}
extension GroupWorkoutsAdapter: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return delegate.numberOfWorkouts()
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: WorkoutTableViewCell.cellID, for: indexPath) as! WorkoutTableViewCell
        cell.configure(with: delegate.getData(at: indexPath))
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate.workoutSelected(at: indexPath)
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
}
extension GroupWorkoutsAdapter: EmptyDataSetSource {
    func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        let str = "No Group Workouts"
        let attrs = [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .headline)]
        return NSAttributedString(string: str, attributes: attrs)
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        let str = "All of the groups workouts will appear here. No workouts have been added to this group yet."
        let attrs = [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .body)]
        return NSAttributedString(string: str, attributes: attrs)
    }
    
    func image(forEmptyDataSet scrollView: UIScrollView) -> UIImage? {
        return UIImage(named: "benchpress_icon")
    }
}
