//
//  MyGroupTableViewCell.swift
//  InTheGym
//
//  Created by Findlay Wood on 07/04/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit

class MyGroupTableViewCell: UITableViewCell {
    
    @IBOutlet weak var groupTitle:UILabel!
    @IBOutlet weak var groupDescription:UITextView!
    
    func setup(with group:groupModel){
        self.groupTitle.text = group.groupTitle
        self.groupDescription.text = group.groupDescription
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
