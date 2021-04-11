//
//  MyInfoTableViewCell.swift
//  InTheGym
//
//  Created by Findlay Wood on 01/04/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit

class MyInfoTableViewCell: UITableViewCell {
    
    @IBOutlet weak var IMAGE:UIImageView!
    @IBOutlet weak var title:UILabel!
    @IBOutlet weak var desc:UITextView!
    
    var data : [String:AnyObject]? {
        didSet {
            title.text = data!["title"] as? String
            IMAGE.image = data!["image"] as? UIImage
            desc.text = data!["description"] as? String
//            let size = width/3 - 40
//            image.translatesAutoresizingMaskIntoConstraints = false
//            image.heightAnchor.constraint(equalToConstant: size).isActive = true
//            image.widthAnchor.constraint(equalToConstant: size).isActive = true
            
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
