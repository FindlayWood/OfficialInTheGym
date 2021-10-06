//
//  DiscoverPageCollectionViewCell.swift
//  InTheGym
//
//  Created by Findlay Wood on 05/01/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit

class DiscoverPageCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var username:UILabel!
    @IBOutlet weak var title:UILabel!
    @IBOutlet weak var imageview:UIImageView!
    @IBOutlet weak var exerciseCount:UILabel!
    @IBOutlet weak var crownImage:UIImageView!
    @IBOutlet weak var wodMessage:UILabel!
    //@IBOutlet weak var downloadCount:UILabel!
    @IBOutlet weak var viewCount:UILabel!
    @IBOutlet weak var averageTime:UILabel!
    @IBOutlet weak var averageScore:UILabel!
    
    func setup(with workout:discoverWorkout){
        self.username.text = workout.createdBy
        self.title.text = workout.title
        self.exerciseCount.text = workout.exercises?.count.description
        self.viewCount.text = workout.views?.description
        //self.downloadCount.text = workout.numberOfDownloads?.description
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.cornerRadius = 8
        
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 3.0)
        self.layer.shadowRadius = 4.0
        self.layer.shadowOpacity = 1.0
        self.layer.masksToBounds = false
    }
}
