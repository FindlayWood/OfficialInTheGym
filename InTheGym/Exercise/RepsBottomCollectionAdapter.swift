//
//  RepsBottomCollectionAdapter.swift
//  InTheGym
//
//  Created by Findlay Wood on 18/05/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import UIKit

protocol repsbottomCollectionProtocol {
    func bottomItemSelected(at index: IndexPath)
    func selectedIndex() -> Int
}

class RepsBottomCollectionAdapter: NSObject {
    var delegate: repsbottomCollectionProtocol!
    init(delegate: repsbottomCollectionProtocol){
        self.delegate = delegate
    }
}

extension RepsBottomCollectionAdapter: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 100
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! SetsCell
        let selected = delegate.selectedIndex()
        if indexPath.item == 0 {
            cell.numberLabel.text = "M"
        } else {
            cell.numberLabel.text = (indexPath.item).description
        }
        if indexPath.item == selected {
            cell.backgroundColor = Constants.darkColour
        }
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate.bottomItemSelected(at: indexPath)
    }
}
