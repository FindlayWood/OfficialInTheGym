//
//  MyGroupTableViewCell.swift
//  InTheGym
//
//  Created by Findlay Wood on 07/04/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit

class MyGroupTableViewCell: UITableViewCell {
    
    @IBOutlet weak var groupTitle:UILabel!
    @IBOutlet weak var groupDescription:UITextView!
    @IBOutlet weak var leaderProfileImage:UIImageView!
    @IBOutlet weak var leaderUsernameLabel:UILabel!
    
    func setup(with group: GroupModel){
        self.groupTitle.text = group.username
        self.groupDescription.text = group.description
        ImageAPIService.shared.getProfileImage(for: group.leader) { (image) in
            self.leaderProfileImage.image = image
        }
        UserIDToUser.transform(userID: group.leader) { (leader) in
            self.leaderUsernameLabel.text = leader.username
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.selectionStyle = .none
        self.layer.cornerRadius = 10
        self.backgroundColor = Constants.offWhiteColour
        self.leaderProfileImage.layer.cornerRadius = self.leaderProfileImage.bounds.width / 2
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
