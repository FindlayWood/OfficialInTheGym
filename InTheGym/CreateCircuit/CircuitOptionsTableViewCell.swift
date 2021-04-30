//
//  CircuitOptionsTableViewCell.swift
//  InTheGym
//
//  Created by Findlay Wood on 28/04/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit

class CircuitOptionsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var title:UILabel!
    @IBOutlet weak var descriptionText:UITextView!
    @IBOutlet weak var switchControl:UISwitch!
    
    var delegate : CircuitOptionsDelegate!
    
    @objc func valueChanged(switchState : UISwitch){
        // delegate to switch bool
        delegate.valueChanged(on: self)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        switchControl.addTarget(self, action: #selector(valueChanged), for: .valueChanged)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
