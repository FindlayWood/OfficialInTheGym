//
//  AppInformationTwoTableViewCell.swift
//  InTheGym
//
//  Created by Findlay Wood on 30/04/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit

class AppInformationTwoTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleText:UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.selectionStyle = .none
        self.titleText.textColor = Constants.darkColour
        self.accessoryType = .disclosureIndicator
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
