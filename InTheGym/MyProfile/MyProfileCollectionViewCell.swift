//
//  MyProfileCollectionViewCell.swift
//  InTheGym
//
//  Created by Findlay Wood on 01/04/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit

class MyProfileCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var displayImage:UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

        self.layer.cornerRadius = self.bounds.width / 2
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.black.cgColor
    }

}
