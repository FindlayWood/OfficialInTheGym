//
//  ProfileButton.swift
//  InTheGym
//
//  Created by Findlay Wood on 09/05/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit

class ProfileButton: UIButton {
    // MARK: - Properties
    
    // MARK: - Subviews
    var label: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.textColor = .darkColour
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.2
        label.isUserInteractionEnabled = false
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var buttonImage: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.backgroundColor = .clear
        view.heightAnchor.constraint(equalToConstant: 30).isActive = true
        view.widthAnchor.constraint(equalToConstant: 30).isActive = true
        view.isUserInteractionEnabled = false
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    lazy var stack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [buttonImage, label])
        stack.axis = .vertical
        stack.spacing = 4
        stack.isUserInteractionEnabled = false
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
private extension ProfileButton {
    func setupUI() {
        backgroundColor = .secondarySystemBackground
        layer.cornerRadius = 8
        addSubview(stack)
        configureUI()
    }
    
    func configureUI() {
        addFullConstraint(to: stack, withConstant: 8)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: stack.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: stack.trailingAnchor)
        ])
    }
}
// MARK: - Public Configuration
extension ProfileButton {
    public func configure(with text: String, and image: UIImage?) {
        label.text = text
        buttonImage.image = image
    }
}
