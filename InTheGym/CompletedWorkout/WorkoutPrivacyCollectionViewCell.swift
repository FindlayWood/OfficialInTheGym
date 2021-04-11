//
//  WorkoutPrivacyCollectionViewCell.swift
//  InTheGym
//
//  Created by Findlay Wood on 05/04/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit

class WorkoutPrivacyCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var privacyImage:UIImageView!
    @IBOutlet weak var privacyLabel:UILabel!
    @IBOutlet weak var descriptionView:UITextView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.backgroundColor = Constants.lightColour
        self.layer.cornerRadius = 10
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.black.cgColor
    }

}
