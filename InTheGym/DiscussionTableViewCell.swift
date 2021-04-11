//
//  DiscussionTableViewCell.swift
//  InTheGym
//
//  Created by Findlay Wood on 23/01/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit

class DiscussionTableViewCell: UITableViewCell {
    
    @IBOutlet weak var username:UILabel!
    @IBOutlet weak var message:UITextView!
    @IBOutlet weak var profileImage:UIImageView!
    @IBOutlet weak var time:UILabel!
    @IBOutlet weak var replyButton:UIButton!
    
    
    // outlets for a workout post
    @IBOutlet weak var creatorLabel:UILabel!
    @IBOutlet weak var workoutTime:UILabel!
    @IBOutlet weak var workoutScore:UILabel!
    @IBOutlet weak var workoutExerciseCount:UILabel!
    @IBOutlet weak var workoutTitle:UILabel!
    @IBOutlet weak var createOrComplete:UILabel!
    
    // icons outlets
    @IBOutlet weak var creatorIcon:UIImageView!
    @IBOutlet weak var exercisesIcon:UIImageView!
    @IBOutlet weak var timeIcon:UIImageView!
    @IBOutlet weak var scoreIcon:UIImageView!

    // the new view
    @IBOutlet weak var workoutView:UIView!
    
    // reply
    @IBOutlet weak var replyIcon:UIImageView!
    @IBOutlet weak var replyLabel:UILabel!
    
    // likes
    @IBOutlet weak var likeButton:UIButton!
    @IBOutlet weak var likeLabel:UILabel!
    
    
    var delegate:workoutTappedDelegate!
    var indexPath:IndexPath!
    
    @IBAction func workoutTapped(_ sender:UIView){
        self.delegate.workoutTapped(at: indexPath)
    }
    
    @IBAction func likeTapped(_ sender:UIButton){
        self.delegate.likeButtonTapped(at: indexPath, sender: sender) 
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
