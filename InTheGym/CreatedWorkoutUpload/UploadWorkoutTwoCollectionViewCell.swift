//
//  UploadWorkoutTwoCollectionViewCell.swift
//  InTheGym
//
//  Created by Findlay Wood on 09/04/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit

class UploadWorkoutTwoCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var title:UILabel!
    @IBOutlet weak var displayImage:UIImageView!
    @IBOutlet weak var desc:UITextView!
    
    func setup(with data:[String:AnyObject]){
        self.title.text = data["title"] as? String
        self.displayImage.image = data["image"] as? UIImage
        self.desc.text = data["description"] as? String
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.layer.cornerRadius = 10
        self.layer.masksToBounds = true
        self.layer.borderWidth = 2
        self.layer.borderColor = UIColor.black.cgColor
    }

}
