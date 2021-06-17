//
//  WeightAdapter.swift
//  InTheGym
//
//  Created by Findlay Wood on 16/06/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import UIKit

class WeightAdapter: NSObject {
    var delegate: WeightAdapterProtocol!
    init(delegate: WeightAdapterProtocol) {
        self.delegate = delegate
    }
}
extension WeightAdapter: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return delegate.numberOfItems()
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! WeightCollectionCell
        cell.setUpData(with: delegate.getData(at: indexPath.item))
        if indexPath.item == delegate.selectedIndex() {
            cell.backgroundColor = Constants.darkColour
        }
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate.itemSelected(at: indexPath.item)
    }
}

protocol WeightAdapterProtocol {
    func getData(at indexPath: Int) -> WeightModel
    func numberOfItems() -> Int
    func itemSelected(at indexPath: Int)
    func selectedIndex() -> Int?
}

struct WeightModel {
    var rep: Int
    var weight: String
    var index: Int
}
