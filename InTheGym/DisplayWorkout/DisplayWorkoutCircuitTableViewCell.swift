//
//  DisplayWorkoutCircuitTableViewCell.swift
//  InTheGym
//
//  Created by Findlay Wood on 28/04/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit

class DisplayWorkoutCircuitTableViewCell: UITableViewCell, workoutCellConfigurable {
    
    @IBOutlet weak var circuitTitle:UILabel!
    @IBOutlet weak var exerciseCount:UILabel!
    @IBOutlet weak var startedLable:UILabel!
    @IBOutlet weak var rpeLable:UILabel!
    
    var delegate:DisplayWorkoutProtocol!
    var circuitModel:circuit!

    
    func setup(with rowModel:WorkoutType){
        circuitModel = rowModel as? circuit
        self.circuitTitle.text = circuitModel.circuitName
        self.exerciseCount.text = "\(circuitModel.exercises?.count ?? 0) exercises"
        self.rpeLable.text = circuitModel.newRPE.value?.description
        
        if let rpe = circuitModel.newRPE.value{
            self.rpeLable.text = rpe.description
            self.rpeLable.textColor = Constants.rpeColors[rpe - 1]
        }
        if let completed = circuitModel.completed.value{
            if completed{
                self.startedLable.text = "COMPLETED"
                self.startedLable.textColor = #colorLiteral(red: 0.00234289733, green: 0.8251151509, blue: 0.003635218529, alpha: 1)
            }
        }
        
        
        
        circuitModel.newRPE.valueChanged = { [weak self] (newRPE) in
            self?.rpeLable.text = newRPE.description
            self?.rpeLable.textColor = Constants.rpeColors[newRPE - 1]
        }
        circuitModel.completed.valueChanged = { [weak self] (newValue) in
            if newValue {
                self?.startedLable.text = "COMPLETED"
                self?.startedLable.textColor = .green
            } else {
                self?.startedLable.text = ""
                self?.startedLable.textColor = .red
            }
            
        }
    }
    
    override func prepareForReuse() {
        circuitModel.completed.valueChanged = nil
        circuitModel.newRPE.valueChanged = nil
        self.startedLable.text = ""
        self.rpeLable.text = "RPE"
        self.rpeLable.textColor = .systemBlue

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
