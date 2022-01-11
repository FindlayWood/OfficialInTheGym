//
//  CreateCircuitAdapter.swift
//  InTheGym
//
//  Created by Findlay Wood on 26/04/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import UIKit
import EmptyDataSet_Swift

class CreateCircuitAdapter:NSObject{
    var delegate:CreateCircuitDelegate!
    init(delegate:CreateCircuitDelegate){
        self.delegate = delegate
    }
}

extension CreateCircuitAdapter: UITableViewDelegate, UITableViewDataSource, EmptyDataSetSource, EmptyDataSetDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return delegate.retreiveNumberOfItems()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == delegate.retreiveNumberOfItems() - 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: NewExerciseCell.cellID, for: indexPath) as! NewExerciseCell
            return cell
        } else {
            let model = delegate.getData(at: indexPath)
            let cell = tableView.dequeueReusableCell(withIdentifier: CircuitCell.cellID, for: indexPath) as! CircuitCell
//            cell.setup(with: model)
            return cell
        }

    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        if indexPath.section == delegate.retreiveNumberOfItems() - 1 {
//            delegate.addNewExercise()
//        }
        if indexPath.section == 1 {
            delegate.addNewExercise()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    // emptydataset functions
    func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        let str = "No Circuit Exercises"
        let attrs = [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .headline)]
        return NSAttributedString(string: str, attributes: attrs)
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        let str = "Add an exercise with the button in the bottom right."
        let attrs = [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .body)]
        return NSAttributedString(string: str, attributes: attrs)
    }
    
    func image(forEmptyDataSet scrollView: UIScrollView) -> UIImage? {
        return UIImage(named: "hammer_icon")
    }
    
    
    
    
}
