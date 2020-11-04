//
//  PlayerInfoCell.swift
//  InTheGym
//
//  Created by Findlay Wood on 13/05/2020.
//  Copyright © 2020 FindlayWood. All rights reserved.
//

import UIKit

class PlayerInfoCell: UITableViewCell {
    
    @IBOutlet weak var coachName:UILabel!
    @IBOutlet weak var coachUsername:UILabel!
    @IBOutlet weak var coachEmail:UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
