//
//  ImageUsernameTimeView.swift
//  InTheGym
//
//  Created by Findlay Wood on 22/05/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit

class PostUserSubview: UIView {
    // MARK: - Properties
    
    // MARK: - Subviews
    var profileImageButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .lightGray
        button.widthAnchor.constraint(equalToConstant: 50).isActive = true
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        button.layer.cornerRadius = 25
        button.clipsToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    var usernameButton: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.titleLabel?.minimumScaleFactor = 0.1
        button.titleLabel?.numberOfLines = 1
        button.titleLabel?.lineBreakMode = .byClipping
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    var timeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 10, weight: .light)
        label.textColor = .lightGray
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.1
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    lazy var usernameTimeVstack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [usernameButton,timeLabel])
        stack.alignment = .leading
        stack.distribution = .fillProportionally
        stack.axis = .vertical
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    lazy var fullStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [profileImageButton,usernameTimeVstack])
        stack.axis = .horizontal
        stack.spacing = 8
        stack.alignment = .top
        stack.distribution = .equalSpacing
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
private extension PostUserSubview {
    func setupUI() {
        addSubview(fullStack)
        configureUI()
    }
    
    func configureUI() {
        NSLayoutConstraint.activate([
            fullStack.topAnchor.constraint(equalTo: topAnchor),
            fullStack.leadingAnchor.constraint(equalTo: leadingAnchor),
            fullStack.trailingAnchor.constraint(equalTo: trailingAnchor),
            fullStack.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}
