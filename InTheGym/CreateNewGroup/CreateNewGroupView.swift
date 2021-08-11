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
    
    var playerLabel: UILabel = {
        let label = UILabel()
        label.text = "PLAYERS"
        label.font = Constants.font
        label.textColor = .black
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
    
    
    // MARK: - Properties
    
    
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

    // MARK: - SetUps
private extension CreateNewGroupView {
    func setUpUI() {
        backgroundColor = Constants.offWhiteColour
        addSubview(groupNameField)
        addSubview(playerLabel)
        addSubview(tableview)
        constrainUI()
    }
    
    func constrainUI() {
        NSLayoutConstraint.activate([groupNameField.topAnchor.constraint(equalTo: topAnchor, constant: 10),
                                     groupNameField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
                                     groupNameField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
                                     groupNameField.heightAnchor.constraint(equalToConstant: 45),
        
                                     playerLabel.topAnchor.constraint(equalTo: groupNameField.bottomAnchor, constant: 10),
                                     playerLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
                                     
                                     tableview.topAnchor.constraint(equalTo: playerLabel.bottomAnchor, constant: 10),
                                     tableview.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
                                     tableview.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
                                     tableview.bottomAnchor.constraint(equalTo: bottomAnchor)
        
        ])
    }
}
