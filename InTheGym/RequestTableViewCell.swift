//
//  RequestTableViewCell.swift
//  InTheGym
//
//  Created by Findlay Wood on 13/07/2019.
//  Copyright © 2019 FindlayWood. All rights reserved.
//

import UIKit

class RequestTableViewCell: UITableViewCell {
    
    // outlet variables inside the request tableview cell
    @IBOutlet var name:UILabel!
    @IBOutlet var acceptButton:UIButton!
    @IBOutlet var declineButton:UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
