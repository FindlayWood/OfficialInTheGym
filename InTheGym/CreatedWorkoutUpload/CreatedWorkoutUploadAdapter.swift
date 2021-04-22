//
//  CreatedWorkoutUploadAdapter.swift
//  InTheGym
//
//  Created by Findlay Wood on 08/04/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import UIKit

class CreatedWorkoutUploadAdapter : NSObject {
    
    var delegate:CreatedWorkoutUploadDelegate!
    init(delegate:CreatedWorkoutUploadDelegate){
        self.delegate = delegate
    }
    
    var width = UIScreen.main.bounds.width
    var height = UIScreen.main.bounds.height
}

extension CreatedWorkoutUploadAdapter: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return delegate.retreiveNumberOfItems()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let data = delegate.getData(at: indexPath)
        
        if indexPath.item == 0 || indexPath.item == 1 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UploadCellOne", for: indexPath) as! UploadWorkoutOneCollectionViewCell
            cell.setup(with: data)
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UploadCellTwo", for: indexPath) as! UploadWorkoutTwoCollectionViewCell
            cell.setup(with: data)
            return cell
        }

    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.item == 0 || indexPath.item == 1 {
            return CGSize(width: (width / 2) - 20, height: height / 8)
        } else {
            return CGSize(width: width - 20, height: height / 6)
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.delegate.itemSelected(at: indexPath)
    }
    
    
}
