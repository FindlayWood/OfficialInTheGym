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
        UserIDToUser.transform(userID: model.posterID!) { (user) in
            if let purl = user.profilePhotoURL{
                DispatchQueue.global(qos: .background).async {
                    let url = URL(string: purl)
                    let data = NSData(contentsOf: url!)
                    let image = UIImage(data: data! as Data)
                    DispatchQueue.main.async {
                        self.profileImage.setImage(image, for: .normal)
                    }
                }
            }else{
                self.profileImage.setImage(UIImage(named: "player_icon"), for: .normal)
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
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func userTapped(_ sender:UIButton){
        self.delegate.userTapped(on: self)
    }
    
}
