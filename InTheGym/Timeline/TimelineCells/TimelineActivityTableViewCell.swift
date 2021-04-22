//
//  TimelineActivityTableViewCell.swift
//  InTheGym
//
//  Created by Findlay Wood on 16/03/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit

class TimelineActivityTableViewCell: UITableViewCell, CellConfiguarable {
    
    @IBOutlet weak var activityImage:UIImageView!
    @IBOutlet weak var message:UITextView!
    @IBOutlet weak var type:UILabel!
    @IBOutlet weak var time:UILabel!
    
    var delegate:TimelineTapProtocol!
    
    func setup(rowViewModel: PostProtocol) {
        let model = rowViewModel as! TimelineActivityModel
        self.activityImage.image = UIImage(named: model.type!)
        self.type.text = model.type
        self.message.text = model.message
        let then = Date(timeIntervalSince1970: model.time! / 1000)
        self.time.text = "\(then.timeAgo()) ago"
    }
    
    static func cellIdentifier() -> String{
        return "TimelineActivityTableViewCell"
    }
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
