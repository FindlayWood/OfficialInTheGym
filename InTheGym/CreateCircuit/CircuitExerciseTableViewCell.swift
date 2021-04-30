//
//  CircuitExerciseTableViewCell.swift
//  InTheGym
//
//  Created by Findlay Wood on 26/04/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit

class CircuitExerciseTableViewCell: UITableViewCell {
    
    @IBOutlet weak var exerciseName:UILabel!
    @IBOutlet weak var setsAndRepsLabel:UILabel!

    func setup(with circuitModel:circuitExercise){
        self.exerciseName.text = circuitModel.exercise
        self.setsAndRepsLabel.text = "\(circuitModel.sets ?? 0) X \(circuitModel.reps ?? 0)"
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.layer.cornerRadius = 10
        self.layer.masksToBounds = true
        self.backgroundColor = .red
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
