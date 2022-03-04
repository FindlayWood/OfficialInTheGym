//
//  AdminPlayersView.swift
//  InTheGym
//
//  Created by Findlay Wood on 04/03/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
import UIKit

class AdminPlayersView: UIView {
    // MARK: - Properties
    
    // MARK: - Subviews
    var iconLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Menlo-Bold", size: 25)
        label.textColor = .darkColour
        label.text = "PLAYERS"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var plusButton: UIButton = {
        let button = UIButton()
        let configuration = UIImage.SymbolConfiguration(pointSize: 22, weight: .semibold)
        button.setImage(UIImage(systemName: "plus.circle.fill", withConfiguration: configuration), for: .normal)
        button.tintColor = .darkColour
        button.isHidden = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    var activityIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView()
        view.widthAnchor.constraint(equalToConstant: 30).isActive = true
        view.heightAnchor.constraint(equalToConstant: 30).isActive = true
        view.hidesWhenStopped = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
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
private extension AdminPlayersView {
    func setupUI() {
        backgroundColor = .white
        addSubview(iconLabel)
        addSubview(plusButton)
        addSubview(activityIndicator)
        addSubview(containerView)
        configureUI()
    }
    
    func configureUI() {
        NSLayoutConstraint.activate([
            iconLabel.topAnchor.constraint(equalTo: topAnchor),
            iconLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            iconLabel.heightAnchor.constraint(equalToConstant: 32),
            
            plusButton.centerYAnchor.constraint(equalTo: iconLabel.centerYAnchor),
            plusButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            activityIndicator.centerYAnchor.constraint(equalTo: plusButton.centerYAnchor),
            activityIndicator.trailingAnchor.constraint(equalTo: plusButton.trailingAnchor),
            
            containerView.topAnchor.constraint(equalTo: iconLabel.bottomAnchor, constant: 16),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}
