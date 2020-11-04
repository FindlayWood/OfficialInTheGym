//
//  GeneralTableViewCell.swift
//  InTheGym
//
//  Created by Findlay Wood on 25/02/2020.
//  Copyright © 2020 FindlayWood. All rights reserved.
//

import UIKit

class GeneralTableViewCell: UITableViewCell {
    
    @IBOutlet weak var imagec:UIImageView!
    @IBOutlet weak var name:UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
