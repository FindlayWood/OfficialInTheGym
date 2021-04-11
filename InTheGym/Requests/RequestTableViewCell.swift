//
//  RequestTableViewCell.swift
//  InTheGym
//
//  Created by Findlay Wood on 13/07/2019.
//  Copyright © 2019 FindlayWood. All rights reserved.
//

import UIKit

class RequestTableViewCell: UITableViewCell {
    
    // outlet variables inside the request tableview cell
    @IBOutlet weak var profileImage:UIButton!
    @IBOutlet var name:UILabel!
    @IBOutlet var acceptButton:UIButton!
    @IBOutlet var declineButton:UIButton!
    
    var delegate:buttonTapsRequestDelegate!
    
    var user : Users? {
        didSet{
            self.name.text = user!.username
            if let purl = user!.profilePhotoURL{
                ImageAPIService.shared.getImage(with: purl) { (image) in
                    if image != nil {
                        self.profileImage.setImage(image, for: .normal)
                    }
                }
            }
        }
    }
    
    @IBAction func acceptPressed(_ sender:UIButton){
        self.delegate.acceptRequest(from: self.user!, on: self)
    }
    
    @IBAction func declinePressed(_ sender:UIButton){
        self.delegate.declineRequest(from: self.user!, on: self)
    }
    
    @IBAction func coachPressed(_ sender:UIButton){
        self.delegate.userTapped(on: self.user!)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.profileImage.layer.cornerRadius = self.profileImage.bounds.width / 2
        self.profileImage.layer.masksToBounds = true
        self.selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
