//
//  DisplayPlusCollectionViewCell.swift
//  InTheGym
//
//  Created by Findlay Wood on 07/03/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit

protocol LiveWorkoutAddMethods {
    func addExercise()
    func addSet(_ cell: UITableViewCell)
}

class DisplayPlusCollectionViewCell: UICollectionViewCell {
    
    var delegate: LiveWorkoutAddMethods!
    var parentCell: UITableViewCell!
    
    @IBOutlet weak var plusButton:UIButton!
    @IBAction func addSet(_ sender: UIButton){
        delegate.addSet(parentCell)
    }
}
