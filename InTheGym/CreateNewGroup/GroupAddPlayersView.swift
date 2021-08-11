//
//  GroupAddPlayersView.swift
//  InTheGym
//
//  Created by Findlay Wood on 09/08/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import UIKit

class GroupAddPlayersView: UIView {
    
    // MARK: - Subviews
    var dismissButton: UIButton = {
        let button = UIButton()
        button.setTitle("Done", for: .normal)
        button.setTitleColor(Constants.darkColour, for: .normal)
        button.titleLabel?.font = UIFont(name: "Menlo-Bold", size: 16)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    var playersLabel: UILabel = {
        let label = UILabel()
        label.font = Constants.font
        label.textColor = Constants.darkColour
        label.text = "Players"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var tableview: UITableView = {
        let view = UITableView()
        view.tableFooterView = UIView()
        view.register(UserTableViewCell.self, forCellReuseIdentifier: UserTableViewCell.cellID)
        
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var loadingIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView()
        view.color = Constants.darkColour
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpUI()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUpUI()
    }
}

//MARK: - SetUp
private extension GroupAddPlayersView {
    func setUpUI() {
        backgroundColor = Constants.offWhiteColour
        addSubview(loadingIndicator)
        addSubview(dismissButton)
        addSubview(playersLabel)
        addSubview(tableview)
        constrainUI()
    }
    
    func constrainUI() {
        NSLayoutConstraint.activate([loadingIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
                                     loadingIndicator.centerYAnchor.constraint(equalTo: centerYAnchor),
                                     
                                     playersLabel.topAnchor.constraint(equalTo: topAnchor, constant: 5),
                                     playersLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
                                     
                                     dismissButton.centerYAnchor.constraint(equalTo: playersLabel.centerYAnchor),
                                     dismissButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -5),
        
                                     tableview.topAnchor.constraint(equalTo: playersLabel.bottomAnchor, constant: 10),
                                     tableview.leadingAnchor.constraint(equalTo: leadingAnchor),
                                     tableview.trailingAnchor.constraint(equalTo: trailingAnchor),
                                     tableview.bottomAnchor.constraint(equalTo: bottomAnchor)])
    }
}
