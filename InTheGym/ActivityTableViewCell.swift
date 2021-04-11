//
//  ActivityTableViewCell.swift
//  InTheGym
//
//  Created by Findlay Wood on 21/07/2019.
//  Copyright © 2019 FindlayWood. All rights reserved.
//

import UIKit

protocol workoutTappedDelegate {
    func workoutTapped(at index: IndexPath)
    func likeButtonTapped(at index: IndexPath, sender: UIButton)
    func userTapped(at index: IndexPath)
}

class ActivityTableViewCell: UITableViewCell {
    
    // workout cell
    @IBOutlet weak var workoutProfilePhoto:UIButton!
    @IBOutlet weak var workoutUsername:UIButton!
    @IBOutlet weak var workoutPostTime:UILabel!
    @IBOutlet weak var createOrComplete:UILabel!
    @IBOutlet weak var workoutView:UIView!
    @IBOutlet weak var workoutTitle:UILabel!
    @IBOutlet weak var creatorIcon:UIImageView!
    @IBOutlet weak var creatorLabel:UILabel!
    @IBOutlet weak var exerciseCountIcon:UIImageView!
    @IBOutlet weak var exerciseCountLabel:UILabel!
    @IBOutlet weak var exerciseTimeIcon:UIImageView!
    @IBOutlet weak var exerciseTimeLabel:UILabel!
    @IBOutlet weak var workoutReplyIcon:UIImageView!
    @IBOutlet weak var workoutReplyLabel:UILabel!
    @IBOutlet weak var workoutLikeButton:UIButton!
    @IBOutlet weak var workoutLikeLabel:UILabel!
    
    // post cell
    @IBOutlet weak var postProfilePhoto:UIButton!
    @IBOutlet weak var postUsername:UIButton!
    @IBOutlet weak var postTime:UILabel!
    @IBOutlet weak var postText:UITextView!
    @IBOutlet weak var postReplyIcon:UIImageView!
    @IBOutlet weak var postReplyLabel:UILabel!
    @IBOutlet weak var postLikeButton:UIButton!
    @IBOutlet weak var postLikeLabel:UILabel!
    
    // activity cell
    @IBOutlet weak var activityIcon:UIImageView!
    @IBOutlet weak var activityType:UILabel!
    @IBOutlet weak var activityTime:UILabel!
    @IBOutlet weak var activityText:UITextView!
    
    
//    // outlet variables for inside the cell
//    @IBOutlet weak var type:UILabel!
//    @IBOutlet weak var time:UILabel!
//    @IBOutlet weak var message:UILabel!
//    @IBOutlet var pic:UIImageView!
//
//    // outlets for written post
//    @IBOutlet weak var username:UILabel!
//    @IBOutlet weak var postTime:UILabel!
//    @IBOutlet weak var postText:UITextView!
//    @IBOutlet weak var profilePhoto:UIImageView!
//    
//    // like button and label
//    @IBOutlet weak var likesLabel:UILabel!
//    @IBOutlet weak var likeButton:UIButton!
//
//    // outlets for a workout post
//    @IBOutlet weak var creatorLabel:UILabel!
//    @IBOutlet weak var workoutTime:UILabel!
//    @IBOutlet weak var workoutScore:UILabel!
//    @IBOutlet weak var workoutExerciseCount:UILabel!
//    @IBOutlet weak var workoutTitle:UILabel!
//    @IBOutlet weak var createOrComplete:UILabel!
//
//    // icons outlets
//    @IBOutlet weak var createdByIcon:UIImageView!
//    @IBOutlet weak var exercisesIcon:UIImageView!
//    @IBOutlet weak var timeIcon:UIImageView!
//    @IBOutlet weak var scoreIcon:UIImageView!
//
//    // the new view
//    @IBOutlet weak var workoutView:UIView!
//
//    // replies
//    @IBOutlet weak var replyIcon:UIImageView!
//    @IBOutlet weak var replyCount:UILabel!
//
//    // who post image
//    @IBOutlet weak var postTypeImage:UIImageView!
//
//    // player icon
//    @IBOutlet weak var playerIcon:UIImageView!
    
    
    
    var delegate:workoutTappedDelegate!
    var indexPath:IndexPath!
    
    
    @IBAction func workoutTapped(_ sender:UIView){
        self.delegate.workoutTapped(at: indexPath)
    }
    
    @IBAction func likeButtonTapped(_ sender:UIButton){
        self.delegate.likeButtonTapped(at: indexPath, sender: sender)
    }
    
    @IBAction func userTapped(_ sender:Any){
        self.delegate.userTapped(at: indexPath)
    }
    

    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        
    }

}
