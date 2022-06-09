//
//  PrivacyView.swift
//  InTheGym
//
//  Created by Findlay Wood on 12/01/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit

class PrivacyView: UIView {
    
    // MARK: - Properties
    var isPrivate: Bool = false
    
    // MARK: - Subviews
    var topLabel: UILabel = {
        let label = UILabel()
        label.text = "Privacy"
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textAlignment = .center
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var privacyButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "public_icon"), for: .normal)
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    var bottomLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.text = "Public"
        label.textColor = .label
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    lazy var stack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [topLabel, privacyButton, bottomLabel])
        stack.axis = .vertical
        stack.spacing = 8
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
private extension PrivacyView {
    func setupUI() {
        backgroundColor = .secondarySystemBackground
        layer.cornerRadius = 8
        layer.borderColor = UIColor.darkColour.cgColor
//        layer.borderWidth = 2
        addSubview(stack)
        configureUI()
    }
    
    func configureUI() {
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8)
        ])
    }
    
    @objc func buttonTapped(_ sender: UIButton) {
        self.isPrivate.toggle()
        let newButtonImage = isPrivate ? UIImage(named: "locked_icon") : UIImage(named: "public_icon")
        privacyButton.setImage(newButtonImage, for: .normal)
        bottomLabel.text = isPrivate ? "Private" : "Public"
    }
}

// MARK: - Public Configuration
extension PrivacyView {
    public func configure(with isPrivate: Bool) {
        let newButtonImage = isPrivate ? UIImage(named: "locked_icon") : UIImage(named: "public_icon")
        privacyButton.setImage(newButtonImage, for: .normal)
        bottomLabel.text = isPrivate ? "Private" : "Public"
    }
}
