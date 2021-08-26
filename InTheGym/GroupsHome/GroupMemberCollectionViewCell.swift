//
//  GroupMemberCollectionViewCell.swift
//  InTheGym
//
//  Created by Findlay Wood on 07/04/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit

class GroupMemberCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var profileImage:UIImageView!
    @IBOutlet weak var usernameLabel:UILabel!

    func setup(with member:Users){
        self.usernameLabel.text = member.username
        ImageAPIService.shared.getProfileImage(for: member.uid) { (image) in
            if let image = image {
                self.profileImage.image = image
            }
        }
//        if let purl = member.profilePhotoURL {
//            ImageAPIService.shared.getImage(with: purl) { (image) in
//                if image != nil {
//                    self.profileImage.image = image
//                }
//            }
//        }
    }
    
    func makeLeader(){
        self.profileImage.layer.borderWidth = 2
        self.profileImage.layer.borderColor = UIColor.yellow.cgColor
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.profileImage.layer.cornerRadius = self.profileImage.bounds.width / 2
        self.profileImage.layer.masksToBounds = true
        
    }

}
