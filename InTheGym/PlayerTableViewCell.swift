//
//  PlayerTableViewCell.swift
//  InTheGym
//
//  Created by Findlay Wood on 20/07/2019.
//  Copyright © 2019 FindlayWood. All rights reserved.
//

import UIKit

class PlayerTableViewCell: UITableViewCell {
    
    // outlet variables inside the player tableview cell
    @IBOutlet weak var name:UILabel!
    @IBOutlet weak var username:UILabel!
    @IBOutlet weak var profilePhoto:UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
