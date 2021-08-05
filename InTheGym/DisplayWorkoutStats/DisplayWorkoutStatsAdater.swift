//
//  DisplayWorkoutStatsAdater.swift
//  InTheGym
//
//  Created by Findlay Wood on 24/06/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import UIKit

class DisplayWorkoutStatsAdapter: NSObject {
    var delegate: WorkoutStatsProtocol!
    init(delegate: WorkoutStatsProtocol) {
        self.delegate = delegate
    }
}

extension DisplayWorkoutStatsAdapter: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return delegate.numberOfCells()
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! DisplayWorkoutStatsCell
        let cellModel = delegate.getData(at: indexPath)
        cell.setupStats(with: cellModel)
        return cell
    }
}
