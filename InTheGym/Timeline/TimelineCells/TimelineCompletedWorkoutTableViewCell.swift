//
//  TimelineCompletedWorkoutTableViewCell.swift
//  InTheGym
//
//  Created by Findlay Wood on 16/03/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit

class TimelineCompletedWorkoutTableViewCell: UITableViewCell, CellConfiguarable {
    
    @IBOutlet weak var profileImage:UIButton!
    @IBOutlet weak var username:UIButton!
    @IBOutlet weak var time:UILabel!
    @IBOutlet weak var workoutView:UIView!
    @IBOutlet weak var workoutTitle:UILabel!
    @IBOutlet weak var creatorLabel:UILabel!
    @IBOutlet weak var exerciseCountLabel:UILabel!
    @IBOutlet weak var exerciseTimeLabel:UILabel!
    @IBOutlet weak var replyCount:UILabel!
    @IBOutlet weak var likeCount:UILabel!
    @IBOutlet weak var likeButton:UIButton!
    
    var delegate : TimelineTapProtocol!
    
    func setup(rowViewModel: PostProtocol) {
        let model = rowViewModel as! TimelineCompletedWorkoutModel
        self.username.setTitle(model.username, for: .normal)
        self.replyCount.text = model.replyCount?.description ?? "0"
        self.likeCount.text = model.likeCount?.description ?? "0"
        self.workoutTitle.text = model.createdWorkout?.title
        self.creatorLabel.text = model.createdWorkout?.createdBy
        self.exerciseCountLabel.text = model.createdWorkout?.exercises?.count.description
        self.exerciseTimeLabel.text = model.createdWorkout?.timeToComplete
        let then = Date(timeIntervalSince1970: (model.time!) / 1000)
        self.time.text = "\(then.timeAgo()) ago"
        
        LikesAPIService.shared.check(postID: model.postID!) { liked in
            if liked {
                if #available(iOS 13.0, *) {
                    self.likeButton.setImage(UIImage(systemName: "star.fill"), for: .normal)
                    self.likeButton.isUserInteractionEnabled = false
                }
            } else {
                if #available(iOS 13.0, *) {
                    self.likeButton.setImage(UIImage(systemName: "star"), for: .normal)
                    self.likeButton.isUserInteractionEnabled = true
                }
            }
        }
        
        ImageAPIService.shared.getProfileImage(for: model.posterID!) { (image) in
            if let image = image {
                self.profileImage.setImage(image, for: .normal)
            }
        }
    }
    
    static func cellIdentifier() -> String{
        return "TimelineCompletedTableViewCell"
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.profileImage.layer.cornerRadius = self.profileImage.bounds.width / 2
        self.profileImage.layer.masksToBounds = true
        self.selectionStyle = .none
        self.workoutView.backgroundColor = #colorLiteral(red: 0.9160451311, green: 0.9251148849, blue: 0.9251148849, alpha: 1)
        self.workoutView.layer.cornerRadius = 10
        self.workoutView.layer.shadowColor = UIColor.black.cgColor
        self.workoutView.layer.shadowOffset = CGSize(width: 0, height: 5.0)
        self.workoutView.layer.shadowRadius = 6.0
        self.workoutView.layer.shadowOpacity = 1.0
        self.workoutView.layer.masksToBounds = false

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        if #available(iOS 13.0, *) {
            self.likeButton.setImage(UIImage(systemName: "star"), for: .normal)
        }
        self.profileImage.setImage(nil, for: .normal)
    }
    
    @IBAction func likeButtonTapped(_ sender:UIButton){
        self.delegate.likeButtonTapped(on: self, sender: sender, label: self.likeCount)
    }
    
    @IBAction func workoutTapped(_ sender:Any){
        self.delegate.workoutTapped(on: self)
    }
    
    @IBAction func userTapped(_ sender:UIButton){
        self.delegate.userTapped(on: self)
    }
    
}
