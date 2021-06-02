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

    func setup(with circuitModel:exercise){
        self.exerciseName.text = circuitModel.exercise
        guard let set = circuitModel.sets else {
            return
        }
        setsAndRepsLabel.text = "\(set) SETS"
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        layer.cornerRadius = 10
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
