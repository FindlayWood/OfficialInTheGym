//
//  FollowersDisplayTableViewCell.swift
//  InTheGym
//
//  Created by Findlay Wood on 12/03/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit

class FollowersDisplayTableViewCell: UITableViewCell {
    
    @IBOutlet weak var profileImage:UIImageView!
    @IBOutlet weak var fullname:UILabel!
    @IBOutlet weak var username:UILabel!

    var user: Users?{
        didSet{
            self.username.text = "@\(user!.username!)"
            self.fullname.text = "\(user!.firstName!) \(user!.lastName!)"
            if let purl = user!.profilePhotoURL{
                ImageAPIService.shared.getImage(with: purl) { (image) in
                    if image != nil {
                        self.profileImage.image = image
                    }
                }
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.profileImage.layer.cornerRadius = self.profileImage.bounds.width / 2
        self.selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
