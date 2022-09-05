//
//  MyJumpsView.swift
//  InTheGym
//
//  Created by Findlay Wood on 22/06/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//
import UIKit

class MyJumpsView: UIView {
    // MARK: - Subviews
    var imageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.backgroundColor = .clear
        view.image = UIImage(named: "jump_icon")
        view.heightAnchor.constraint(equalToConstant: 100).isActive = true
        view.widthAnchor.constraint(equalToConstant: 100).isActive = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var welcomeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 100, weight: .bold)
        label.textColor = .label
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.1
        label.text = "Jump Measurement"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var subMessageLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.text = "Welcome to the vertical jump measurement. Here you can measure the height of your vertical jump. Save jumps to the database to keep track of your jump history."
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var newJumpButton: UIButton = {
        let button = UIButton()
        button.setTitle("Record New Jump", for: .normal)
        button.setTitleColor(.label, for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 18)
        button.backgroundColor = .systemBackground
        button.layer.cornerRadius = 8
        button.contentHorizontalAlignment = .left
        button.contentEdgeInsets.left = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    var helpButton: UIButton = {
        let button = UIButton()
        button.setTitle("How to Use Vertical Jump System", for: .normal)
        button.setTitleColor(.label, for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 18)
        button.backgroundColor = .systemBackground
        button.layer.cornerRadius = 8
        button.contentHorizontalAlignment = .left
        button.contentEdgeInsets.left = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    var myJumpsButton: UIButton = {
        let button = UIButton()
        button.setTitle("My Previous Jumps", for: .normal)
        button.setTitleColor(.label, for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 18)
        button.backgroundColor = .systemBackground
        button.layer.cornerRadius = 8
        button.contentHorizontalAlignment = .left
        button.contentEdgeInsets.left = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    lazy var stack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [imageView,welcomeLabel, subMessageLabel,newJumpButton, helpButton,myJumpsButton])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 8
        stack.setCustomSpacing(16, after: subMessageLabel)
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
private extension MyJumpsView {
    func setupUI() {
        backgroundColor = .secondarySystemBackground
        addSubview(stack)
        configureUI()
    }
    func configureUI() {
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor),
            stack.bottomAnchor.constraint(lessThanOrEqualTo: safeAreaLayoutGuide.bottomAnchor),
            
            welcomeLabel.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.9),
            subMessageLabel.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.8),
            newJumpButton.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.9),
            newJumpButton.heightAnchor.constraint(equalToConstant: 48),
            helpButton.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.9),
            helpButton.heightAnchor.constraint(equalToConstant: 48),
            myJumpsButton.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.9),
            myJumpsButton.heightAnchor.constraint(equalToConstant: 48)
        ])
    }
}
