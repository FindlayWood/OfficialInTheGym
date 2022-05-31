//
//  AddPlayerView.swift
//  InTheGym
//
//  Created by Findlay Wood on 31/05/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit

class AddPlayerView: UIView {
    // MARK: - Properties
    
    // MARK: - Subview
    var playerIcon: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.backgroundColor = .clear
        view.image = UIImage(named: "player_icon")
        view.heightAnchor.constraint(equalToConstant: 100).isActive = true
        view.widthAnchor.constraint(equalToConstant: 100).isActive = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var messageLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.text = "Search for players based on their usernames (case sensitive). You can view a player's profile by tapping on them. Make sure you know the user before you send a request."
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var searchField: UISearchBar = {
        let view = UISearchBar()
        view.placeholder = "search usernames..."
        view.showsCancelButton = true
        view.searchBarStyle = .prominent
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var tableview: UITableView = {
        let view = UITableView()
        view.register(UserTableViewCell.self, forCellReuseIdentifier: UserTableViewCell.cellID)
        view.register(CoachRequestTableViewCell.self, forCellReuseIdentifier: CoachRequestTableViewCell.cellID)
        view.tableFooterView = UIView()
        view.backgroundColor = .secondarySystemBackground
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var activityIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView()
        view.widthAnchor.constraint(equalToConstant: 30).isActive = true
        view.heightAnchor.constraint(equalToConstant: 30).isActive = true
        view.hidesWhenStopped = true
        view.color = .darkColour
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var dismissButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "xmark", withConfiguration: UIImage.SymbolConfiguration(scale: .large)), for: .normal)
        button.tintColor = .darkColour
        button.heightAnchor.constraint(equalToConstant: 30).isActive = true
        button.widthAnchor.constraint(equalToConstant: 30).isActive = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
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
private extension AddPlayerView {
    func setupUI() {
        addSubview(searchField)
        addSubview(playerIcon)
        addSubview(messageLabel)
        addSubview(tableview)
        addSubview(activityIndicator)
        addSubview(dismissButton)
        configureUI()
    }
    func configureUI() {
        NSLayoutConstraint.activate([
            activityIndicator.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            activityIndicator.trailingAnchor.constraint(equalTo: trailingAnchor),
            dismissButton.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            dismissButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            
            playerIcon.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 32),
            playerIcon.centerXAnchor.constraint(equalTo: centerXAnchor),
            
            messageLabel.topAnchor.constraint(equalTo: playerIcon.bottomAnchor, constant: 8),
            messageLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            messageLabel.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.7),
            
            searchField.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 8),
            searchField.leadingAnchor.constraint(equalTo: leadingAnchor),
            searchField.trailingAnchor.constraint(equalTo: trailingAnchor),
            searchField.heightAnchor.constraint(equalToConstant: 48),
            
            tableview.topAnchor.constraint(equalTo: searchField.bottomAnchor),
            tableview.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableview.trailingAnchor.constraint(equalTo: trailingAnchor),
            tableview.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}
