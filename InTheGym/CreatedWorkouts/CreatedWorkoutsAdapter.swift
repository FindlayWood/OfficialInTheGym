//
//  CreatedWorkoutsAdapter.swift
//  InTheGym
//
//  Created by Findlay Wood on 01/04/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import UIKit
import EmptyDataSet_Swift

class CreatedWorkoutsAdapter: NSObject {
    
    var delegate : CreatedWorkoutsProtocol
    
    
    init(delegate: CreatedWorkoutsProtocol){
        self.delegate = delegate
    }
    
    
}

extension CreatedWorkoutsAdapter : UITableViewDataSource, UITableViewDelegate, EmptyDataSetSource, EmptyDataSetDelegate{
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let workoutModel = delegate.getData(at: indexPath)
        switch workoutModel {
        case is PublicCreatedWorkout:
            let cell = tableView.dequeueReusableCell(withIdentifier: "PublicCreatedWorkoutCell", for: indexPath) as! PublicCreatedWorkoutTableViewCell
            cell.setup(workoutModel: workoutModel as! PublicCreatedWorkout)
            return cell
        case is PrivateCreatedWorkout:
            let cell = tableView.dequeueReusableCell(withIdentifier: "PrivateCreatedWorkoutCell", for: indexPath) as! PrivateCreatedWorkoutTableViewCell
            cell.setup(workoutModel: workoutModel as! PrivateCreatedWorkout)
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return delegate.retreiveNumberOfItems()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return delegate.retreiveNumberOfSections()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate.itemSelected(at: indexPath)
    }
    
    
    // emptydataset functions
    func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        let str = "No Created Workouts"
        let attrs = [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .headline)]
        return NSAttributedString(string: str, attributes: attrs)
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        let str = "All the workouts you create will appear here. It seems you haven't created any yet."
        let attrs = [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .body)]
        return NSAttributedString(string: str, attributes: attrs)
    }
    
    func image(forEmptyDataSet scrollView: UIScrollView) -> UIImage? {
        return UIImage(named: "hammer_icon")
    }
}
