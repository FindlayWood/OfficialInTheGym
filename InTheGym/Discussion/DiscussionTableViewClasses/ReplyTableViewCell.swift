//
//  ReplyTableViewCell.swift
//  InTheGym
//
//  Created by Findlay Wood on 25/03/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit

class ReplyTableViewCell: UITableViewCell, DiscussionCellConfigurable {
    
    @IBOutlet weak var profileImage:UIButton!
    @IBOutlet weak var username:UIButton!
    @IBOutlet weak var time:UILabel!
    @IBOutlet weak var message:UITextView!
    @IBOutlet weak var likeButton:UIButton!
    @IBOutlet weak var likeCount:UILabel!
    
    var delegate:DiscussionTapProtocol!
    
    func setup(rowViewModel: PostProtocol) {
        let model = rowViewModel as! DiscussionReply
        self.message.text = model.message
        self.username.setTitle(model.username, for: .normal)
        let then = Date(timeIntervalSince1970: (model.time!) / 1000)
        self.time.text = "\(then.timeAgo()) ago"
        ImageAPIService.shared.getProfileImage(for: model.posterID!) { (image) in
            if let image = image {
                self.profileImage.setImage(image, for: .normal)
            }
        }
    }
    
    static func cellIdentifier() -> String{
        return "ReplyTableViewCell"
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.profileImage.layer.cornerRadius = self.profileImage.bounds.width / 2
        self.profileImage.layer.masksToBounds = true
        self.selectionStyle = .none
        self.message.layer.cornerRadius = 5
        self.message.backgroundColor = Constants.offWhiteColour
        self.message.textColor = .darkGray
        self.message.sizeToFit()
        self.message.textContainerInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        profileImage.setImage(nil, for: .normal)
    }
    
    @IBAction func userTapped(_ sender:UIButton){
        self.delegate.userTapped(on: self)
    }
    
}
