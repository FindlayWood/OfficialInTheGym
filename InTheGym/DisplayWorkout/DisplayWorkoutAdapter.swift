//
//  DisplayWorkoutAdapter.swift
//  InTheGym
//
//  Created by Findlay Wood on 06/03/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import UIKit


class DisplayWorkoutAdapter:NSObject {
    
    var delegate : DisplayWorkoutProtocol
    
    
    init(delegate: DisplayWorkoutProtocol){
        self.delegate = delegate
    }
      
}

extension DisplayWorkoutAdapter: UITableViewDataSource, UITableViewDelegate, WorkoutTableCellTapDelegate {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if delegate.isLive() && indexPath.section == delegate.retreiveNumberOfItems(){
            
            // here will go the plus cell
            let cell = tableView.dequeueReusableCell(withIdentifier: "DisplayPlusTableView", for: indexPath) as! DisplayPlusTableViewCell
            return cell
            
        }else{
            
            // here will go the normal cell
            let cell = tableView.dequeueReusableCell(withIdentifier: "DisplayWorkoutCell", for: indexPath) as! DisplayWorkoutTableViewCell
            
            cell.exercise = delegate.getData(at: indexPath)
            cell.isLive = delegate.isLive()
            cell.collection.reloadData()
            cell.collection.contentInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
            cell.collection.scrollToItem(at: IndexPath(item: 0, section: 0), at: .left, animated: false)
            cell.delegate = self.delegate as NSObject as? WorkoutTableCellTapDelegate
            cell.cellDelegate = self.delegate
            cell.rpeButton.isUserInteractionEnabled = delegate.returnInteractionEnbabled()
            cell.noteButton.isUserInteractionEnabled = delegate.returnInteractionEnbabled()
            
            return cell
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return delegate.retreiveNumberOfSections()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 25
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel()
        label.text = "EXERCISE \(section+1)"
        label.font = .boldSystemFont(ofSize: 15)
        label.font = .preferredFont(forTextStyle: UIFont.TextStyle(rawValue: "Menlo Bold"))
        label.backgroundColor = Constants.lightColour
        label.textAlignment = .center
        label.textColor = UIColor.white
        
        return label
    }
    
    func noteButtonTapped(on tableviewcell: UITableViewCell) {
        delegate.noteButtonTapped(on: tableviewcell)
    }
    
    func rpeButtonTappped(on tableviewcell: UITableViewCell, sender: UIButton, collection: UICollectionView) {
        delegate.rpeButtonTappped(on: tableviewcell, sender: sender, collection: collection)
    }
    
    func completedCell(on tableviewcell: UITableViewCell, on item: Int, sender: UIButton, with cell:UICollectionViewCell) {
        delegate.completedCell(on: tableviewcell, on: item, sender: sender, with: cell)
    }
    
}
