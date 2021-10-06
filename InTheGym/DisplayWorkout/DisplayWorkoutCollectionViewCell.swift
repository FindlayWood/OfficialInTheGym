//
//  DisplayWorkoutCollectionViewCell.swift
//  InTheGym
//
//  Created by Findlay Wood on 07/03/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit

class DisplayWorkoutCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var repsLabel:UILabel!
    @IBOutlet weak var weightLabel:UILabel!
    @IBOutlet weak var setLabels:UILabel!
    @IBOutlet weak var completedButton:UIButton!
    
    var delegate:WorkoutTableCellTapDelegate!
    
    var model : CollectionCellModel! {
        didSet{
            self.setLabels.text = "Set \(model.set!)"
            if let rep = model.reps {
                if rep == 0 {
                    repsLabel.text = "MAX reps"
                } else {
                    self.repsLabel.text = rep.description + " reps"
                }
            } else {
                self.repsLabel.text = ""
            }
            self.weightLabel.text = model.weight
            if model.completed == true {
                self.completedButton.setImage(UIImage(named: "tickRing"), for: .normal)
                self.completedButton.isUserInteractionEnabled = false
                self.backgroundColor = Constants.darkColour
            }else{
                self.completedButton.setImage(UIImage(named: "emptyRing"), for: .normal)
                self.completedButton.isUserInteractionEnabled = true
                self.backgroundColor = Constants.lightColour
            }
            if model.time != nil || model.restTime != nil || model.distance != nil {
                self.layer.borderWidth = 4
            }
        }
    }
    
    @IBAction func completedTapped(_ sender:UIButton){
        delegate.completedCell(on: model.parentTableViewCell!, on: model.set! - 1, sender: sender, with: self)
    }
    
    override func awakeFromNib() {
        self.layer.borderColor = UIColor.black.cgColor
        self.contentView.layer.cornerRadius = 10
        self.contentView.layer.borderWidth = 2
        self.contentView.layer.borderColor = UIColor.black.cgColor
        self.contentView.layer.masksToBounds = true
        
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 5.0)
        self.layer.shadowRadius = 6.0
        self.layer.shadowOpacity = 1.0
        self.layer.masksToBounds = false
        
        self.layer.cornerRadius = 10
        
        
    }
    
}
