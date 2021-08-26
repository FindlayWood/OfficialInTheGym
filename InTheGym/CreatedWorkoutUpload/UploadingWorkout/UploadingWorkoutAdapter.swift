//
//  UploadingWorkoutAdapter.swift
//  InTheGym
//
//  Created by Findlay Wood on 23/08/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit

class UploadingWorkoutAdapter: NSObject {
    var delegate: UploadingWorkoutProtocol
    init(delegate: UploadingWorkoutProtocol) {
        self.delegate = delegate
    }
}

extension UploadingWorkoutAdapter: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return delegate.numberOfItems()
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let rowModel = delegate.getData(at: indexPath)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.cellIdentifier(for: rowModel), for: indexPath)
        if var cell = cell as? UploadCellConfigurable {
            cell.setup(with: rowModel)
            cell.delegate = delegate
        }
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let textview = UITextView()
        let text = delegate.getData(at: indexPath).message
        
        textview.text = text
        textview.font = UIFont.systemFont(ofSize: 14, weight: .medium)

        let actualsize = textview.sizeThatFits(CGSize(width: Constants.screenSize.width - 75, height: CGFloat.greatestFiniteMagnitude))
        
        return CGSize(width: Constants.screenSize.width - 20,
                      height: actualsize.height + 40)
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate.itemSelected(at: indexPath)
    }
}

private extension UploadingWorkoutAdapter {
    func cellIdentifier(for item: UploadCellModelProtocol) -> String {
        switch item {
        case is SavingUploadCellModel:
            return SavingUploadCell.reuseIdentifier
        case is PrivacyUploadCellModel:
            return PrivacyUploadCell.reuseIdentifier
        default:
            return "error"
        }
    }
}
