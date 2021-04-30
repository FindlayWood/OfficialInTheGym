//
//  AppInformationTableViewCell.swift
//  InTheGym
//
//  Created by Findlay Wood on 30/04/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit

class AppInformationTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleText:UILabel!
    @IBOutlet weak var descriptionText:UITextView!
    @IBOutlet weak var additionalInfo:UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        titleText.textColor = Constants.darkColour
        descriptionText.textColor = .darkGray
        additionalInfo.textColor = Constants.darkColour
        self.selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        self.additionalInfo.text = ""
    }
    
}
