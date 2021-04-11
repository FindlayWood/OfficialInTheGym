//
//  ProfileCollectionViewCell.swift
//  InTheGym
//
//  Created by Findlay Wood on 03/03/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit

class ProfileCollectionViewCell: UICollectionViewCell {
    
    let width = UIScreen.main.bounds.width
    let height = UIScreen.main.bounds.height
    
    @IBOutlet weak var image:UIImageView!
    @IBOutlet weak var label:UILabel!
    @IBOutlet weak var textDescription:UITextView!
    
    var data : [String:AnyObject]? {
        didSet {
            label.text = data!["title"] as? String
            image.image = data!["image"] as? UIImage
            textDescription.text = data!["description"] as? String
//            let size = width/3 - 40
//            image.translatesAutoresizingMaskIntoConstraints = false
//            image.heightAnchor.constraint(equalToConstant: size).isActive = true
//            image.widthAnchor.constraint(equalToConstant: size).isActive = true
            
        }
    }
    
    
}
