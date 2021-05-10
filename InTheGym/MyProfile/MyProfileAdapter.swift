//
//  MyProfileAdapter.swift
//  InTheGym
//
//  Created by Findlay Wood on 31/03/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import UIKit

class MyProfileAdapter: NSObject {
    
    var delegate:MyProfileProtocol!
    
    init(delegate:MyProfileProtocol){
        self.delegate = delegate
    }
    
}

extension MyProfileAdapter: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return delegate.retreiveNumberOfItems()
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: "MyProfileCollectionTableViewCell", for: indexPath) as! MyProfileCollectionTableViewCell
            cell.collectionData = delegate.getCollectionData()
            cell.delegate = self.delegate
            return cell
            
        } else {
            let rowModel = delegate.getData(at: indexPath)
            let cell = tableView.dequeueReusableCell(withIdentifier: self.cellIdentifier(for: rowModel), for: indexPath)
            if var cell = cell as? CellConfiguarable{
                cell.setup(rowViewModel: rowModel)
                cell.delegate = self.delegate as? TimelineTapProtocol
            }
            return cell
            
            
        }
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return delegate.retreiveNumberOfSections()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 1 {
            delegate.itemSelected(at: indexPath)
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 5
        } else {
            return 25
        }
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            let view = UIView()
//            if #available(iOS 13.0, *) {
//                view.backgroundColor = .systemGray5
//            } else {
//                view.backgroundColor = .lightGray
//            }
            view.backgroundColor = Constants.darkColour
            return view
        } else {
            let label = UILabel()
            label.text = "POSTS"
            label.font = .boldSystemFont(ofSize: 20)
            //label.font = .preferredFont(forTextStyle: UIFont.TextStyle(rawValue: "Menlo Bold"))
            label.backgroundColor = .white
            label.textAlignment = .center
            label.textColor = Constants.darkColour
            return label
        }

    }
    
    private func cellIdentifier(for rowModel:PostProtocol) -> String{
        switch rowModel{
        case is TimelinePostModel:
            return TimelinePostTableViewCell.cellIdentifier()
        case is TimelineCreatedWorkoutModel:
            return TimelineCreatedWorkoutTableViewCell.cellIdentifier()
        case is TimelineCompletedWorkoutModel:
            return TimelineCompletedWorkoutTableViewCell.cellIdentifier()
        case is TimelineActivityModel:
            return TimelineActivityTableViewCell.cellIdentifier()
        default:
            return "Unexpected row model type \(rowModel)"
        }
    }
}
