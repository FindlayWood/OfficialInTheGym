//
//  ActivityTableViewCell.swift
//  InTheGym
//
//  Created by Findlay Wood on 21/07/2019.
//  Copyright © 2019 FindlayWood. All rights reserved.
//

import UIKit

class ActivityTableViewCell: UITableViewCell {
    
    // outlet variables for inside the cell
    @IBOutlet weak var type:UILabel!
    @IBOutlet weak var time:UILabel!
    @IBOutlet weak var message:UILabel!
    @IBOutlet var pic:UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        
    }

}
