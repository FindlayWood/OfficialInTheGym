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
    
    var lastContentOffset: CGFloat = 0
    
    init(delegate: DisplayWorkoutProtocol){
        self.delegate = delegate
    }
      
}

extension DisplayWorkoutAdapter: UITableViewDataSource, UITableViewDelegate, WorkoutTableCellTapDelegate {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if (delegate.isLive() || delegate.isCreatingNew()) && indexPath.section + 1 == delegate.retreiveNumberOfSections(){
            
            // here will go the plus cell
            let cell = tableView.dequeueReusableCell(withIdentifier: "DisplayPlusTableView", for: indexPath) as! DisplayPlusTableViewCell
            cell.delegate = self.delegate
            return cell
            
        }else{
            let rowModel = delegate.getData(at: indexPath)
            let cell = tableView.dequeueReusableCell(withIdentifier: self.cellIdentifier(for: rowModel), for: indexPath)
            if var cell = cell as? workoutCellConfigurable {
                cell.delegate = self.delegate
                cell.setup(with: rowModel)
            }
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate.itemSelected(at: indexPath)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.lastContentOffset = scrollView.contentOffset.y
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if lastContentOffset + 100 < scrollView.contentOffset.y {
            delegate.hideClips()
        } else if lastContentOffset > scrollView.contentOffset.y {
            delegate.showClips()
        } else if scrollView.contentOffset.y == 0 {
            delegate.showClips()
        }
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
    
    func clipButtonTapped(on tableviewcell: UITableViewCell) {
        delegate.clipButtonTapped(on: tableviewcell)
    }
    
    private func cellIdentifier(for rowModel: WorkoutType) -> String{
        switch rowModel{
        case is exercise:
            return "DisplayWorkoutCell"
        case is circuit:
            return "DisplayWorkoutCircuitTableViewCell"
        case is AMRAP:
            return DisplayAMRAPCell.cellID
        case is EMOM:
            return DisplayEMOMCell.cellID
        default:
            return "Unexpected row model type \(rowModel)"
        }
    }
}

extension DisplayWorkoutAdapter: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return delegate.returnNumberOfClips()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! DisplayClipCell
        let clipData = delegate.getClipData(at: indexPath)
        cell.attachThumbnail(from: clipData.clipKey)
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate.clipSelected(at: indexPath)
    }
    
}
