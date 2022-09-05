//
//  PerformanceIntorSubview.swift
//  InTheGym
//
//  Created by Findlay Wood on 26/07/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit

class PerformanceIntroSubview: UIView {
    // MARK: - Properties
    var option: PerformanceIntroOptions
    // MARK: - Subviews
    lazy var imageView: UIImageView = {
        let view = UIImageView()
        view.image = option.image
        view.tintColor = .darkColour
        view.backgroundColor = .clear
        view.widthAnchor.constraint(equalToConstant: 50).isActive = true
        view.heightAnchor.constraint(equalToConstant: 50).isActive = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .title2, weight: .semibold)
        label.adjustsFontForContentSizeCategory = true
        label.textColor = .label
        label.text = option.title
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    lazy var hstack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [imageView, titleLabel])
        stack.axis = .horizontal
        stack.spacing = 8
        return stack
    }()
    lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .body)
        label.textColor = .secondaryLabel
        label.textAlignment = .left
        label.numberOfLines = 0
        label.text = option.message
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var actionButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.buttonSize = .large
        config.cornerStyle = .capsule
        config.image = UIImage(systemName: "chevron.right")
        config.baseBackgroundColor = .darkColour
        config.baseForegroundColor = .white
        let button = UIButton(configuration: config)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    lazy var stack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [hstack, messageLabel])
        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    // MARK: - Initializer
    init(option: PerformanceIntroOptions) {
        self.option = option
        super.init(frame: .zero)
        setupUI()
    }
    required init?(coder: NSCoder) {
        fatalError("Failed to init coder")
    }
}
// MARK: - Configure
private extension PerformanceIntroSubview {
    func setupUI() {
        backgroundColor = .systemBackground
        layer.cornerRadius = 8
        addSubview(stack)
        addSubview(actionButton)
        configureUI()
    }
    func configureUI() {
        NSLayoutConstraint.activate([
            actionButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),
            actionButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            stack.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            stack.bottomAnchor.constraint(equalTo: actionButton.topAnchor, constant: -26)
        ])
    }
}
