//
//  DisplayAMRAPAdapter.swift
//  InTheGym
//
//  Created by Findlay Wood on 08/06/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import UIKit

class DisplayAMRAPAdapter: NSObject {
    
    var delegate: DisplayAMRAPProtocol!
    init(delegate: DisplayAMRAPProtocol){
        self.delegate = delegate
    }
}
extension DisplayAMRAPAdapter: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return delegate.numberOfExercises() * 100
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! DisplayAMRAPCollectionCell
        let exerciseModel = delegate.getExercise(at: indexPath)
        cell.setup(with: exerciseModel)
        cell.delegate = delegate
        return cell
    }
}
