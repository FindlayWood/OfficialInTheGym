//
//  AssignView.swift
//  InTheGym
//
//  Created by Findlay Wood on 12/01/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit

class AssignView: UIView {
    // MARK: - Properties
    var isPrivate: Bool = false
    
    // MARK: - Subviews
    var topLabel: UILabel = {
        let label = UILabel()
        label.text = "Assign To"
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textAlignment = .center
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var profileImage: UIButton = {
        let button = UIButton()
        button.imageView?.contentMode = .scaleAspectFit
        button.layer.cornerRadius = 25
        button.widthAnchor.constraint(equalToConstant: 50).isActive = true
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    var bottomLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.textColor = .lightGray
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    lazy var stack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [topLabel, profileImage, bottomLabel])
        stack.axis = .vertical
        stack.spacing = 8
        stack.alignment = .center
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
private extension AssignView {
    func setupUI() {
        backgroundColor = .lightColour
        layer.cornerRadius = 8
        layer.borderColor = UIColor.black.cgColor
        layer.borderWidth = 2
        addSubview(stack)
        configureUI()
    }
    
    func configureUI() {
        NSLayoutConstraint.activate([
//            profileImage.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.4),
//            profileImage.heightAnchor.constraint(equalTo: profileImage.heightAnchor),
            stack.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8)
        ])
    }
}

// MARK: - Public Configuration
extension AssignView {
    public func configure(with user: Users) {
        bottomLabel.text = user.username
        ImageAPIService.shared.getProfileImage(for: user.id) { [weak self] image in
            if let image = image {
                guard let self = self else {return}
                self.profileImage.setImage(image, for: .normal)
            }
        }
    }
}
