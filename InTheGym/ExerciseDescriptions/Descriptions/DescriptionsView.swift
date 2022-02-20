//
//  DescriptionsView.swift
//  InTheGym
//
//  Created by Findlay Wood on 16/02/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
import UIKit

class DescriptionsView: UIView {
    // MARK: - Properties
    
    // MARK: - Subviews
    var tableview: UITableView = {
        let view = UITableView()
        view.register(DescriptionTableViewCell.self, forCellReuseIdentifier: DescriptionTableViewCell.cellID)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var plusButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "bluePlus3"), for: .normal)
        button.widthAnchor.constraint(equalToConstant: 100).isActive = true
        button.heightAnchor.constraint(equalToConstant: 100).isActive = true
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
private extension DescriptionsView {
    func setupUI() {
        addSubview(tableview)
        addSubview(plusButton)
        configureUI()
    }
    
    func configureUI() {
        NSLayoutConstraint.activate([
            tableview.topAnchor.constraint(equalTo: topAnchor),
            tableview.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableview.trailingAnchor.constraint(equalTo: trailingAnchor),
            tableview.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            plusButton.trailingAnchor.constraint(equalTo: tableview.trailingAnchor, constant: -5),
            plusButton.bottomAnchor.constraint(equalTo: tableview.bottomAnchor, constant: -5)
        ])
    }
}
