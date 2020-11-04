//
//  NewInfoTableViewCell.swift
//  InTheGym
//
//  Created by Findlay Wood on 01/10/2020.
//  Copyright © 2020 FindlayWood. All rights reserved.
//

import UIKit

class NewInfoTableViewCell: UITableViewCell {
    
    @IBOutlet weak var QLabel:UILabel!
    @IBOutlet weak var ALabel:UILabel!
    
    @IBOutlet var pic:UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
