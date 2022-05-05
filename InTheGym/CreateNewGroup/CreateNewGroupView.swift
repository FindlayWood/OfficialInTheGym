//
//  CreateNewGroupView.swift
//  InTheGym
//
//  Created by Findlay Wood on 09/08/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import UIKit
import SkyFloatingLabelTextField

class CreateNewGroupView: UIView {

    // MARK: - SubViews
    var groupNameField: SkyFloatingLabelTextField = {
        let field = SkyFloatingLabelTextField()
        field.tintColor = Constants.darkColour
        field.returnKeyType = .done
        field.textColor = .black
        field.placeholderColor = .lightGray
        field.selectedLineHeight = 4
        field.lineHeight = 2
        field.titleColor = .black
        field.lineColor = .lightGray
        field.title = "enter group name"
        field.selectedTitle = "Group Name"
        field.selectedTitleColor = Constants.darkColour
        field.selectedLineColor = Constants.darkColour
        field.placeholder = "enter group name"
        field.clearButtonMode = .whileEditing
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    var textView: UITextView = {
        let view = UITextView()
        view.addToolBar()
        view.font = .systemFont(ofSize: 14, weight: .medium)
        view.textColor = .darkGray
        view.isScrollEnabled = false
        view.isUserInteractionEnabled = false
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var groupImageButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .lightGray
        button.setImage(UIImage(systemName: "plus"), for: .normal)
        button.layer.cornerRadius = 8
        button.tintColor = .darkColour
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    var playerLabel: UILabel = {
        let label = UILabel()
        label.text = "PLAYERS"
        label.font = Constants.font
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var addPlayersButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "plus.circle.fill"), for: .normal)
        button.tintColor = .darkColour
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    var tableview: UITableView = {
        let view = UITableView()
        view.tableFooterView = UIView()
        view.register(UserTableViewCell.self, forCellReuseIdentifier: UserTableViewCell.cellID)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    
    // MARK: - Properties
    
    
    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: UIScreen.main.bounds)
        setUpUI()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUpUI()
    }
}

// MARK: - Setup UI
private extension CreateNewGroupView {
    func setUpUI() {
        backgroundColor = .secondarySystemBackground
        addSubview(groupNameField)
        addSubview(groupImageButton)
        addSubview(playerLabel)
        addSubview(addPlayersButton)
        addSubview(tableview)
        constrainUI()
    }
    
    func constrainUI() {
        NSLayoutConstraint.activate([
            
            groupImageButton.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 8),
            groupImageButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            groupImageButton.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.2),
            groupImageButton.heightAnchor.constraint(equalTo: widthAnchor, multiplier: 0.2),
            
            groupNameField.bottomAnchor.constraint(equalTo: groupImageButton.bottomAnchor),
            groupNameField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            groupNameField.heightAnchor.constraint(equalToConstant: 45),
            groupNameField.trailingAnchor.constraint(equalTo: groupImageButton.leadingAnchor, constant: -8),
            
            
            playerLabel.topAnchor.constraint(equalTo: groupNameField.bottomAnchor, constant: 16),
            playerLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            
            addPlayersButton.centerYAnchor.constraint(equalTo: playerLabel.centerYAnchor),
            addPlayersButton.leadingAnchor.constraint(equalTo: playerLabel.trailingAnchor, constant: 8),
            
            tableview.topAnchor.constraint(equalTo: playerLabel.bottomAnchor, constant: 8),
            tableview.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            tableview.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            tableview.bottomAnchor.constraint(equalTo: bottomAnchor)
        
        ])
    }
}
