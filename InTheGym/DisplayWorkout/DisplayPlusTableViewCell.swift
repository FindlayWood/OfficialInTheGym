//
//  DisplayPlusTableViewCell.swift
//  InTheGym
//
//  Created by Findlay Wood on 07/03/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit

class DisplayPlusTableViewCell: UITableViewCell {
    
    var delegate: LiveWorkoutAddMethods!
    
    @IBOutlet weak var plusButton:UIButton!
    @IBAction func addExercise(_ sender: UIButton) {
        delegate.addExercise()
    }
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
