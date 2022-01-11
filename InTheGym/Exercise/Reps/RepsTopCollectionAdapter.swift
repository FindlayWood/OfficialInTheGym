//
//  RepsTopCollectionAdapter.swift
//  InTheGym
//
//  Created by Findlay Wood on 18/05/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import UIKit

protocol repsTopCollectionProtocol {
    func retreiveNumberOfItems() -> Int
    func getData(at index: IndexPath) -> Int
    func itemSelected(at indec: IndexPath)
    func selectedIndex() -> Int?
}

class RepsTopCollectionAdapter: NSObject {
    var delegate: repsTopCollectionProtocol!
    init(delegate: repsTopCollectionProtocol){
        self.delegate = delegate
    }
}

//MARK: - Set up the collection view methods
extension RepsTopCollectionAdapter: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return delegate.retreiveNumberOfItems()
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RepsCell.cellID, for: indexPath) as! RepsCell
        cell.setLabel.text = "SET \((indexPath.item + 1).description)"
        let rep = delegate.getData(at: indexPath)
        if rep == 0 {
            cell.repLabel.text = "max reps"
        } else {
            cell.repLabel.text = "\(rep) reps"
        }
        
        if indexPath.item == delegate.selectedIndex() {
            cell.backgroundColor = .darkColour
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate.itemSelected(at: indexPath)
    }
}
