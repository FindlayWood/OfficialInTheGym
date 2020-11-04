//
//  RepsTableViewCell.swift
//  InTheGym
//
//  Created by Findlay Wood on 15/10/2020.
//  Copyright © 2020 FindlayWood. All rights reserved.
//

import UIKit

class RepsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var setsLabel:UILabel!
    @IBOutlet weak var repsText:UITextField!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
