//
//  WorkoutCompletedAdapter.swift
//  InTheGym
//
//  Created by Findlay Wood on 04/04/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import UIKit

class WorkoutCompletedAdapter : NSObject {
    
    var delegate : WorkoutCompletedProtocol!
    let width = UIScreen.main.bounds.width
    let height = UIScreen.main.bounds.height
    
    init( delegate : WorkoutCompletedProtocol) {
        self.delegate = delegate
    }
}

extension WorkoutCompletedAdapter : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return delegate.retreiveNumberOfItems()
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return delegate.retreiveNumberOfSections()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.item == 2{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WorkoutPrivacyCollectionViewCell", for: indexPath) as! WorkoutPrivacyCollectionViewCell
            if delegate.isPrivate() {
                cell.privacyImage.image = UIImage(named: "locked_icon")
                cell.privacyLabel.text = "Private"
                cell.descriptionView.text = "This is private. It will only be seen by your followers and coaches/players. Tap to change."
            } else {
                cell.privacyImage.image = UIImage(named: "public_icon")
                cell.privacyLabel.text = "Public"
                cell.descriptionView.text = "This is public. It will be seen by all your followers and players/coaches and anyone who views your public profile. Tap to change."
            }
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WorkoutCompletedCollectionViewCell", for: indexPath) as! WorkoutCompletedCollectionViewCell
            let data = delegate.getData(at: indexPath)
            cell.displayImage.image = data["image"] as? UIImage
            cell.title.text = data["title"] as? String
            cell.disaplyData.text = data["data"] as? String
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if indexPath.item == 2{
            return CGSize(width: width-20, height: 110)
        }else{
            return CGSize(width: width/2-15, height: 100)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate.itemSelected(at: indexPath)
    }
    
    
}
