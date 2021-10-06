//
//  ExerciseSelectionAdapter.swift
//  InTheGym
//
//  Created by Findlay Wood on 03/09/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit

class ExerciseSelectionAdapter: NSObject {
    var delegate: ExerciseSelectionProtocol
    init(delegate: ExerciseSelectionProtocol) {
        self.delegate = delegate
    }
}
extension ExerciseSelectionAdapter: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return delegate.numberOfSections()
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return delegate.numberOfItems(at: section)
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ExerciseSelectionCell.reuseIdentifier, for: indexPath) as! ExerciseSelectionCell
        cell.configure(with: delegate.getData(at: indexPath))
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: ExerciseSelectionHeader.reuseIdentifier, for: indexPath) as! ExerciseSelectionHeader
        header.setup(section: indexPath.section)
        return header
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate.itemSelected(at: indexPath)
    }
}
