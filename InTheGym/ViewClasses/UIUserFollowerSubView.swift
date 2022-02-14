//
//  UIUserFollowerSubView.swift
//  InTheGym
//
//  Created by Findlay Wood on 10/02/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
import UIKit

class UIUserFollowerSubView: UIView {
    // MARK: - Properties
    
    // MARK: - Subviews
    var followerCountButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    var followingCountButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    var accountTypeButton: UIButton = {
        let button = UIButton()
        button.imageView?.contentMode = .scaleToFill
        button.widthAnchor.constraint(equalToConstant: 30).isActive = true
        button.heightAnchor.constraint(equalToConstant: 30).isActive = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    var followerLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .medium)
        label.textColor = .black
        label.text = "Followers"
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var followingLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .medium)
        label.textColor = .black
        label.text = "Following"
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var accountTypeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .medium)
        label.textColor = .black
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var followerStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [followerCountButton, followerLabel])
        stack.axis = .vertical
        stack.spacing = 4
        stack.alignment = .center
        stack.distribution = .fill
        return stack
    }()
    
    lazy var followingStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [followingCountButton, followingLabel])
        stack.axis = .vertical
        stack.spacing = 4
        stack.alignment = .center
        stack.distribution = .fill
        return stack
    }()
    lazy var accountTypeStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [accountTypeButton, accountTypeLabel])
        stack.axis = .vertical
        stack.spacing = 4
        stack.alignment = .center
        stack.distribution = .fill
        return stack
    }()
    
    var mainStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 8
        stack.distribution = .fillEqually
        stack.alignment = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
}
// MARK: - Configure
private extension UIUserFollowerSubView {
    func setupUI() {
        mainStack.addArrangedSubview(followerStack)
        mainStack.addArrangedSubview(followingStack)
        mainStack.addArrangedSubview(accountTypeStack)
        addSubview(mainStack)
        configureUI()
    }
    
    func configureUI() {
        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: topAnchor),
            mainStack.leadingAnchor.constraint(equalTo: leadingAnchor),
            mainStack.trailingAnchor.constraint(equalTo: trailingAnchor),
            mainStack.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}

// MARK: - Public Configuration
extension UIUserFollowerSubView {
    public func configure(admin: Bool) {
        let image: UIImage = admin ? UIImage(named: "coach_icon")! : UIImage(named: "player_icon")!
        accountTypeButton.setImage(image, for: .normal)
        let accountType: String = admin ? "Coach" : "Player"
        accountTypeLabel.text = accountType
    }
    public func setFollowers(to count: Int) {
        followerCountButton.setTitle(count.description, for: .normal)
    }
    public func setFollowing(to count: Int) {
        followingCountButton.setTitle(count.description, for: .normal)
    }
}
