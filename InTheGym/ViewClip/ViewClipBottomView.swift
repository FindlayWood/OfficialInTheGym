//
//  ViewClipBottomView.swift
//  InTheGym
//
//  Created by Findlay Wood on 27/07/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import UIKit

protocol ClipMoreDelegate {
    func userProfileTapped()
    func tableViewTapped(at position: Int)
}

class ViewClipBottomView: UIView {
    
    var flashview: FlashView! {
        didSet {
            let tap = UITapGestureRecognizer(target: self, action: #selector(remove))
            flashview.addGestureRecognizer(tap)
        }
    }
    
    var tableContents = ["View Creator Profile", "View Workout"]
    
    var delegate: ClipMoreDelegate!
    
    var titleLabel: UILabel = {
        let label = UILabel()
        label.font = Constants.font
        label.textColor = Constants.darkColour
        label.text = "MORE"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var profileImageButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 40
        button.layer.borderWidth = 1.0
        button.backgroundColor = .lightGray
        button.clipsToBounds = true
        button.layer.masksToBounds = true
        button.layer.borderColor = UIColor.black.cgColor
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    var usernameButton: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = Constants.font
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.titleLabel?.minimumScaleFactor = 0.5
        button.setTitleColor(.black, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpView()
    }
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    private func setUpView() {
        isUserInteractionEnabled = true
        backgroundColor = .white
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        layer.cornerRadius = 20
        clipsToBounds = true
        addSubview(titleLabel)
        addSubview(profileImageButton)
        addSubview(usernameButton)
        profileImageButton.addTarget(self, action: #selector(userTapped(_:)), for: .touchUpInside)
        usernameButton.addTarget(self, action: #selector(userTapped(_:)), for: .touchUpInside)
        constrain()
    }
    
    private func constrain() {
        NSLayoutConstraint.activate([titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10),
                                     titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
        
                                     profileImageButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
                                     profileImageButton.centerYAnchor.constraint(equalTo: centerYAnchor),
                                     profileImageButton.widthAnchor.constraint(equalToConstant: 80),
                                     profileImageButton.heightAnchor.constraint(equalToConstant: 80),
        
                                     usernameButton.centerYAnchor.constraint(equalTo: profileImageButton.centerYAnchor),
                                     usernameButton.centerXAnchor.constraint(equalTo: centerXAnchor),
                                     usernameButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
                                     usernameButton.leadingAnchor.constraint(equalTo: profileImageButton.trailingAnchor, constant: 20)])
    }
    
    @objc private func remove() {
        let hiddenFrame = CGRect(x: 0, y: Constants.screenSize.height, width: frame.width, height: frame.height)
        UIView.animate(withDuration: 0.3) {
            self.frame = hiddenFrame
            self.flashview.alpha = 0
        } completion: { _ in
            self.flashview.removeFromSuperview()
            self.removeFromSuperview()
        }
    }
    
    func setProfileImage(from userID: String) {
        ImageAPIService.shared.getProfileImage(for: userID) { [weak self] profileImage in
            guard let self = self else {return}
            if let image = profileImage {
                self.profileImageButton.setImage(image, for: .normal)
            }
        }
    }
    
    func setUsername(from userID: String) {
        UserIDToUser.transform(userID: userID) { [weak self] user in
            guard let self = self else {return}
            self.usernameButton.setTitle(user.username, for: .normal)
        }
    }
    
    @objc func userTapped(_ sender: UIButton) {
        self.delegate.userProfileTapped()
    }
}
