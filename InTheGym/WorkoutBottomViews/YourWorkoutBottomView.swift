//
//  YourWorkoutBottomView.swift
//  InTheGym
//
//  Created by Findlay Wood on 22/04/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import UIKit


class YourWorkoutBottomView: UIView {
    
    var parentView:UIView!
    var newHeightAnchor:NSLayoutConstraint?
    
    init(parent:UIView) {
        self.parentView = parent
        super.init(frame: CGRect.zero)
        setup()
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup(){
        self.backgroundColor = .white
        self.layer.cornerRadius = 10
        self.layer.borderWidth = 2
        self.layer.borderColor = UIColor.black.cgColor
        self.translatesAutoresizingMaskIntoConstraints = false
        parentView.addSubview(self)
        self.bottomAnchor.constraint(equalTo: self.parentView.bottomAnchor).isActive = true
        self.leadingAnchor.constraint(equalTo: self.parentView.leadingAnchor).isActive = true
        self.trailingAnchor.constraint(equalTo: self.parentView.trailingAnchor).isActive = true
        
        newHeightAnchor = self.heightAnchor.constraint(equalTo: self.parentView.heightAnchor, multiplier: 0.15)
        newHeightAnchor?.isActive = true
        
        let addButton = UIButton()
        addButton.setTitle("Your Workout", for: .normal)
        addButton.backgroundColor = Constants.darkColour
        addButton.titleLabel?.font = UIFont(name: "Menlo-Bold", size: 25)
        addButton.layer.cornerRadius = 10
        addButton.layer.borderWidth = 2
        addButton.layer.borderColor = UIColor.black.cgColor
        addButton.translatesAutoresizingMaskIntoConstraints = false
        addButton.isUserInteractionEnabled = false
        
        self.addSubview(addButton)
        
        addButton.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 25).isActive = true
        addButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -25).isActive = true
        addButton.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        addButton.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        addButton.heightAnchor.constraint(equalToConstant: 49).isActive = true
        

    }
    
}
