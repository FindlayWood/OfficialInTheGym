//
//  NotificationsTableViewCell.swift
//  InTheGym
//
//  Created by Findlay Wood on 15/03/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit
import Firebase

class NotificationsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var profileImage:UIButton!
    @IBOutlet weak var message:UILabel!
    @IBOutlet weak var timeLabel:UILabel!
    
    var notification: NotificationTableViewModel? {
        didSet{
            self.message.text = (notification?.from?.username!)! + " "  + (notification?.message!)!

            let then = Date(timeIntervalSince1970: (notification?.time)! / 1000)
            
            self.timeLabel.text = "\(then.timeAgo()) ago"
            
            ImageAPIService.shared.getProfileImage(for: notification!.from!.uid!) { (image) in
                if let image = image {
                    self.profileImage.setImage(image, for: .normal)
                }
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.profileImage.layer.cornerRadius = self.profileImage.bounds.width / 2
        self.profileImage.layer.masksToBounds = true
        self.selectionStyle = .none
    }
    override func prepareForReuse() {
        self.profileImage.setImage(nil, for: .normal)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
