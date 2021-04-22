//
//  DiscoverPageAdapter.swift
//  InTheGym
//
//  Created by Findlay Wood on 15/04/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import UIKit

class DiscoverPageAdapter: NSObject {
    
    var delegate:DiscoverPageProtocol!
    init(delegate:DiscoverPageProtocol){
        self.delegate = delegate
    }
    let width = UIScreen.main.bounds.width
    let height = UIScreen.main.bounds.height
}

extension DiscoverPageAdapter : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0{
            return delegate.retrieveWOD() ? 1 : 0
        } else {
            return delegate.retreiveNumberOfWorkouts()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! DiscoverPageCollectionViewCell
        if indexPath.section == 0{
            let wod = delegate.getWOD()
            cell.setup(with: wod)
            cell.crownImage.isHidden = false
            cell.wodMessage.isHidden = false
            return cell
        } else {
            let workout = delegate.getWorkout(at: indexPath)
            cell.setup(with: workout)
            cell.crownImage.isHidden = true
            cell.wodMessage.isHidden = true
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate.workoutSelected(at: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.section == 0{
            return CGSize(width: width-10, height: height/5)
        }else{
            return CGSize(width: width/2-10, height: width/2.5)
        }
    }

    
    
}
