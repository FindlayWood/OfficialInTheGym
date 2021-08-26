//
//  AddMoreToExerciseAdapter.swift
//  InTheGym
//
//  Created by Findlay Wood on 21/08/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit

class AddMoreToExerciseAdapter: NSObject {
    var delegate: AddMoreToExerciseProtocol!
    init(delegate: AddMoreToExerciseProtocol) {
        self.delegate = delegate
    }
}
extension AddMoreToExerciseAdapter: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return delegate.numberOfItems()
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if #available(iOS 13.0, *) {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CardCollectionViewCell.reuseIdentifier, for: indexPath) as! CardCollectionViewCell
            cell.configure(with: delegate.getData(at: indexPath), parent: delegate as! UIViewController)
            cell.clipsToBounds = true
            cell.layer.cornerRadius = 10
            return cell
        } else {
            return UICollectionViewCell()
        }

    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: Constants.screenSize.width / 2 - 20,
                      height: Constants.screenSize.height / 4)
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate.itemSelected(at: indexPath)
    }
}
