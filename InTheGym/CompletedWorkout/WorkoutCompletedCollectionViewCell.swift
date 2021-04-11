//
//  WorkoutCompletedCollectionViewCell.swift
//  InTheGym
//
//  Created by Findlay Wood on 04/04/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit

class WorkoutCompletedCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var displayImage:UIImageView!
    @IBOutlet weak var title:UILabel!
    @IBOutlet weak var disaplyData:UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.backgroundColor = Constants.lightColour
        self.layer.cornerRadius = 10
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.black.cgColor
    }

}
