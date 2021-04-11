//
//  TimeLineTableViewCell.swift
//  InTheGym
//
//  Created by Findlay Wood on 10/02/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit

class TimeLineTableViewCell: UITableViewCell {
    
    @IBOutlet weak var profileImage:UIImageView!
    @IBOutlet weak var username:UILabel!
    @IBOutlet weak var time:UILabel!
    @IBOutlet weak var workoutView:UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
