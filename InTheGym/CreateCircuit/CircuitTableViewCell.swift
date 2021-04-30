//
//  CircuitTableViewCell.swift
//  InTheGym
//
//  Created by Findlay Wood on 27/04/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit

class CircuitTableViewCell: UITableViewCell {
    
    @IBOutlet weak var dataTextField:UITextField!
    
    var placeholder : String? {
        didSet{
            guard let item = placeholder else {
                return
            }
            self.dataTextField.placeholder = item
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.dataTextField.tintColor = Constants.darkColour
        self.dataTextField.returnKeyType = .done
        self.dataTextField.autocapitalizationType = .words
        self.dataTextField.layer.cornerRadius = 4
        self.layer.masksToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
