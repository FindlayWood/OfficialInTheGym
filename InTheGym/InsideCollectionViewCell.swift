//
//  InsideCollectionViewCell.swift
//  InTheGym
//
//  Created by Findlay Wood on 20/10/2020.
//  Copyright © 2020 FindlayWood. All rights reserved.
//

import UIKit

protocol CollectionViewCompleted {
    func completionTapped(at index:IndexPath, sender:UIButton, section: Int, with cell: UICollectionViewCell)
}

class InsideCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var repsLabel:UILabel!
    @IBOutlet weak var weightLabel:UILabel!
    @IBOutlet weak var setLabels:UILabel!
    @IBOutlet weak var completedButton:UIButton!
    
    
    var delegate:CollectionViewCompleted!
    var indexPath:IndexPath!
    var collectionIndex:Int!
    
    @IBAction func tappedRing(_ sender:UIButton){
        self.delegate.completionTapped(at: indexPath, sender: sender, section: collectionIndex, with: self)
    }
    
}
