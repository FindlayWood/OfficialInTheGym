//
//  ActivityTableViewCell.swift
//  InTheGym
//
//  Created by Findlay Wood on 21/07/2019.
//  Copyright © 2019 FindlayWood. All rights reserved.
//

import UIKit

class ActivityTableViewCell: UITableViewCell {
    
    // outlet variables for inside the cell
    @IBOutlet weak var type:UILabel!
    @IBOutlet weak var time:UILabel!
    @IBOutlet weak var message:UILabel!
    @IBOutlet var pic:UIImageView!
    
    // outlets for written post
    @IBOutlet weak var username:UILabel!
    @IBOutlet weak var postTime:UILabel!
    @IBOutlet weak var postText:UITextView!
    @IBOutlet weak var profilePhoto:UIImageView!
    
    // like button and label
    @IBOutlet weak var likesLabel:UILabel!
    @IBOutlet weak var likeButton:UIButton!
    
    // outlets for a workout post
    @IBOutlet weak var workoutTime:UILabel!
    @IBOutlet weak var workoutScore:UILabel!
    @IBOutlet weak var workoutExerciseCount:UILabel!
    @IBOutlet weak var workoutTitle:UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        
    }

}
