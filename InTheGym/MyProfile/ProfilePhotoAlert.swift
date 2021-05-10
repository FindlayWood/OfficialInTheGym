//
//  ProfilePhotoAlert.swift
//  InTheGym
//
//  Created by Findlay Wood on 10/05/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import UIKit

class ProfilePhotoAlert: UIView {
    
    var editProfile: (()->Void)?
    
    lazy var message: UILabel = {
        let label = UILabel()
        label.text = "Tap here to add a profile photo."
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.textColor = .white
        label.textAlignment = .center
        label.backgroundColor = .clear
        label.isUserInteractionEnabled = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var dismissButton: UIButton = {
        let button = UIButton()
        button.setTitle("dismiss", for: .normal)
        button.setTitleColor(.red, for: .normal)
        button.backgroundColor = .clear
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        button.addTarget(self, action: #selector(dismiss), for: .touchUpInside)
        button.isUserInteractionEnabled = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        backgroundColor = Constants.darkColour
        addShadow()
        addSubview(message)
        addSubview(dismissButton)
        isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(tappedChange))
        message.addGestureRecognizer(tap)
        setupLayout()
    }
    
    private func addShadow() {
        layer.cornerRadius = 10
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 1.0
        layer.shadowRadius = 6.0
    }
    
    private func setupLayout() {
        NSLayoutConstraint.activate([ message.centerYAnchor.constraint(equalTo: centerYAnchor),
                                      message.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
                                      
                                      dismissButton.centerYAnchor.constraint(equalTo: centerYAnchor),
                                      dismissButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10)
        ])
        //animateAppearance()
    }
    
    private func animateAppearance() {
        let showingPoint = CGRect(x: 0, y: 40, width: UIScreen.main.bounds.width, height: 40)
        UIView.animate(withDuration: 0.3) {
            self.frame = showingPoint
        }
    }
    
    override class var requiresConstraintBasedLayout: Bool {
        return true
    }
    
    @objc func dismiss() {
        let dismissPoint = CGRect(x: 5, y: -60, width: UIScreen.main.bounds.width - 10, height: 60)
        UIView.animate(withDuration: 0.3) {
            self.frame = dismissPoint
        } completion: { _ in
            self.removeFromSuperview()
        }
    }
    
    @objc func tappedChange() {
        editProfile?()
        removeFromSuperview()
    }
    
}
