//
//  DisplayCircuitExerciseTableViewCell.swift
//  InTheGym
//
//  Created by Findlay Wood on 29/04/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit

class DisplayCircuitExerciseTableViewCell: UITableViewCell {
    
    @IBOutlet weak var exerciseName:UILabel!
    @IBOutlet weak var exerciseSet:UILabel!
    @IBOutlet weak var exerciseReps:UILabel!
    @IBOutlet weak var completedButton:UIButton!
    
    var delegate : DisplayCircuitProtocol!
    
    func setup(with rowModel:CircuitTableModel){
        self.exerciseName.text = rowModel.exerciseName
        let rep = rowModel.reps
        if rep == 0 {
            exerciseReps.text = "MAX"
        } else {
            self.exerciseReps.text = "\(rep) reps"
        }
        self.exerciseSet.text = "Set \(rowModel.set.description)"
        if rowModel.completed{
            self.completedButton.setImage(UIImage(named: "tickRing"), for: .normal)
            self.completedButton.tintColor = Constants.lightColour
            self.completedButton.isUserInteractionEnabled = false
        } else {
            self.completedButton.setImage(UIImage(named: "emptyRing"), for: .normal)
            self.completedButton.isUserInteractionEnabled = delegate.isButtonInteractionEnabled()
            self.completedButton.tintColor = Constants.lightColour
        }
    }
    
    @IBAction func completeExercise(_ sender:UIButton){
        delegate.completedExercise(on: self)
        sender.setImage(UIImage(named: "tickRing"), for: .normal)
        sender.isUserInteractionEnabled = false
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.backgroundColor = Constants.offWhiteColour
        self.layer.cornerRadius = 10
        self.layer.masksToBounds = true
        self.selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
