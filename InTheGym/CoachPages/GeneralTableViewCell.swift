//
//  GeneralTableViewCell.swift
//  InTheGym
//
//  Created by Findlay Wood on 25/02/2020.
//  Copyright © 2020 FindlayWood. All rights reserved.
//

import UIKit


protocol addWorkout {
    func sendToWorkoutPage(sender:UIButton, at index:IndexPath)
}

class GeneralTableViewCell: UITableViewCell {
    
    
    // outlets to all cells except the last one
    @IBOutlet weak var title:UILabel!
    @IBOutlet weak var subTitle:UILabel!
    @IBOutlet weak var playerCount:UILabel!
    @IBOutlet weak var addWorkoutButton:UIButton!
    
    // ooutlet for last tableview cell
    @IBOutlet weak var addButton:UIButton!
    
    var delegate:addWorkout!
    var indexPath:IndexPath!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func sendToWorkoutPage(_ sender:UIButton){
        self.delegate?.sendToWorkoutPage(sender: sender, at: indexPath)
        
    }

}
