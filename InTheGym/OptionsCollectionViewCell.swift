//
//  OptionsCollectionViewCell.swift
//  InTheGym
//
//  Created by Findlay Wood on 08/05/2020.
//  Copyright © 2020 FindlayWood. All rights reserved.
//

import UIKit

class OptionsCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var image:UIImageView!
    @IBOutlet weak var label:UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.contentView.autoresizingMask.insert(.flexibleHeight)
        self.contentView.autoresizingMask.insert(.flexibleWidth)
    }
    
}

