//
//  AdminPlayersView.swift
//  InTheGym
//
//  Created by Findlay Wood on 04/03/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
import UIKit
import Combine

class AdminPlayersView: UIView {
    // MARK: - Publishers
    var myWorkoutsSelected = PassthroughSubject<Void,Never>()
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
    var iconButton: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = UIFont(name: "Menlo-Bold", size: 25)
        button.setTitleColor(.darkColour, for: .normal)
        button.setTitle("PLAYERS", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
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
    var tableview: UITableView = {
        let view = UITableView()
        view.register(UserTableViewCell.self, forCellReuseIdentifier: UserTableViewCell.cellID)
        view.tableFooterView = UIView()
        view.separatorStyle = .none
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var coachMenu: UIMenu {
        let menu = UIMenu(title: "Options", children: [
            UIAction(title: "My Workouts") { action in
                self.myWorkoutsSelected.send(())
            }
        ])
        return menu
    }
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
        backgroundColor = .secondarySystemBackground
        addSubview(iconButton)
        addSubview(plusButton)
        addSubview(activityIndicator)
        addSubview(tableview)
        configureUI()
    }
    func configureUI() {
        NSLayoutConstraint.activate([
            iconButton.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            iconButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            iconButton.heightAnchor.constraint(equalToConstant: 32),
            
            plusButton.centerYAnchor.constraint(equalTo: iconButton.centerYAnchor),
            plusButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            activityIndicator.centerYAnchor.constraint(equalTo: plusButton.centerYAnchor),
            activityIndicator.trailingAnchor.constraint(equalTo: plusButton.trailingAnchor),
            
            tableview.topAnchor.constraint(equalTo: iconButton.bottomAnchor, constant: 16),
            tableview.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableview.trailingAnchor.constraint(equalTo: trailingAnchor),
            tableview.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}
