//
//  CMJHomeCurrentScoreView.swift
//  InTheGym
//
//  Created by Findlay Wood on 01/07/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit

class CMJCurrentScoreView: UIView {
    // MARK: - Properties
    
    // MARK: - Subviews
    var currentHeight: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .largeTitle, weight: .bold)
        label.textColor = .label
        label.text = "45"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var currentHeightLabelMessage: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .body, weight: .regular)
        label.textColor = .secondaryLabel
        label.text = "Current Height"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var heightImage: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(systemName: "arrow.up")
        view.tintColor = .green
        view.contentMode = .scaleAspectFit
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    lazy var heightStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [currentHeight, currentHeightLabelMessage, heightImage])
        stack.axis = .vertical
        stack.spacing = 8
        stack.alignment = .center
        return stack
    }()
    var currentPower: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .largeTitle, weight: .bold)
        label.textColor = .label
        label.text = "89"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var currentPowerLabelMessage: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .body, weight: .regular)
        label.textColor = .secondaryLabel
        label.text = "Current Power"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var powerImage: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(systemName: "arrow.down")
        view.tintColor = .red
        view.contentMode = .scaleAspectFit
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    lazy var powerStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [currentPower, currentPowerLabelMessage, powerImage])
        stack.axis = .vertical
        stack.spacing = 8
        stack.alignment = .center
        return stack
    }()
    lazy var hstack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [heightStack, powerStack])
        stack.axis = .horizontal
        stack.spacing = 16
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemBackground
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var lastJumpLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .footnote, weight: .regular)
        label.text = "Last Jump: 25/07/22"
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
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
private extension CMJCurrentScoreView {
    func setupUI() {
        backgroundColor = .systemBackground
        layer.cornerRadius = 8
        addSubview(hstack)
        addSubview(separatorView)
        addSubview(lastJumpLabel)
        configureUI()
    }
    
    func configureUI() {
        NSLayoutConstraint.activate([
            lastJumpLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            lastJumpLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
            
            separatorView.bottomAnchor.constraint(equalTo: lastJumpLabel.topAnchor, constant: -8),
            separatorView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            separatorView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            separatorView.heightAnchor.constraint(equalToConstant: 1),
            
            hstack.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            hstack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            hstack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            hstack.bottomAnchor.constraint(equalTo: separatorView.topAnchor, constant: -16)
        ])
    }
}
