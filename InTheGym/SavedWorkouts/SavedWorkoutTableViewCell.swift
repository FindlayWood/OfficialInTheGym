//
//  SavedWorkoutTableViewCell.swift
//  InTheGym
//
//  Created by Findlay Wood on 04/03/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit

class SavedWorkoutTableViewCell: UITableViewCell {
    
    @IBOutlet weak var title:UILabel!
    @IBOutlet weak var createdBy:UILabel!
    @IBOutlet weak var exerciseCount:UILabel!
    @IBOutlet weak var averageTime:UILabel!
    @IBOutlet weak var averageScore:UILabel!
    
    @IBOutlet weak var createdByIcon:UIImageView!
    @IBOutlet weak var exerciseCountIcon:UIImageView!
    @IBOutlet weak var averageTimeIcon:UIImageView!
    
    var workout: publicSavedWorkout! {
        didSet {
            title.text = workout?.title
            createdBy.text = workout?.createdBy
            exerciseCount.text = workout?.exercises?.count.description
            myFunc(with: workout.totalScore ?? 0, and: workout.completes ?? 0, and: workout.totalTime ?? 0)

        }
    }
    
    func myFunc(with score:Int, and completes:Int, and time:Int){
        let averageTime = Double(time) / Double(completes)
        let average = Double(score) / Double(completes)
        let rounded = round(average * 10)/10
        if rounded.isNaN{
            self.averageScore.text = "0"
        }else{
            self.averageScore.text = rounded.description
        }
        if averageTime.isNaN{
            self.averageTime.text = "0"
        }else{
            let formatter = DateComponentsFormatter()
            
            if averageTime > 3600{
                formatter.allowedUnits = [.hour, .minute]
                formatter.unitsStyle = .abbreviated
            }else{
                formatter.allowedUnits = [.minute, .second]
                formatter.unitsStyle = .abbreviated
            }
            
            let timeString = formatter.string(from: TimeInterval(averageTime))
            self.averageTime.text = timeString
        }
        
    }
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.layer.cornerRadius = 10
        self.selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
