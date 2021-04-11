//
//  SearchUsersTableViewCell.swift
//  InTheGym
//
//  Created by Findlay Wood on 07/01/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit

class SearchUsersTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var profileImage:UIImageView!
    @IBOutlet weak var username:UILabel!
    @IBOutlet weak var fullName:UILabel!
    @IBOutlet weak var userBio:UITextView!
    
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
