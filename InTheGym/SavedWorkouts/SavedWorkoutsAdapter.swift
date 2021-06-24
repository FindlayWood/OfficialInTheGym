//
//  SavedWorkoutsAdapter.swift
//  InTheGym
//
//  Created by Findlay Wood on 03/03/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import UIKit
import EmptyDataSet_Swift

class SavedWorkoutsAdapter: NSObject {
    
    var delegate : SavedWorkoutsProtocol
    
    
    init(delegate: SavedWorkoutsProtocol){
        self.delegate = delegate
    }
    
    
}

extension SavedWorkoutsAdapter : UITableViewDataSource, UITableViewDelegate, EmptyDataSetSource, EmptyDataSetDelegate{
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch delegate.getData(at: indexPath) {
        case is publicSavedWorkout:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SavedWorkoutCell", for: indexPath) as! SavedWorkoutTableViewCell
            cell.workout = delegate.getData(at: indexPath) as? publicSavedWorkout
            return cell
        case is privateSavedWorkout:
            let cell = tableView.dequeueReusableCell(withIdentifier: "PrivateSavedWorkoutCell", for: indexPath) as! PrivateSavedWorkoutTableViewCell
            cell.workout = delegate.getData(at: indexPath) as? privateSavedWorkout
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
        let view = UIView()
        view.backgroundColor = Constants.lightColour
        return view
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate.itemSelected(at: indexPath)
    }
    
    // emptydataset functions
    func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        let str = "No Saved Workouts"
        let attrs = [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .headline)]
        return NSAttributedString(string: str, attributes: attrs)
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        let str = "All the workouts you have saved will appear here. It seems you haven't saved any yet."
        let attrs = [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .body)]
        return NSAttributedString(string: str, attributes: attrs)
    }
    
    func image(forEmptyDataSet scrollView: UIScrollView) -> UIImage? {
        return UIImage(named: "benchpress_icon")
    }
}
