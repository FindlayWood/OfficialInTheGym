//
//  MyGroupsView.swift
//  InTheGym
//
//  Created by Findlay Wood on 31/12/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import UIKit

class MyGroupsView: UIView {
    // MARK: - Properties
    
    // MARK: - Subviews
    var tableview: UITableView = {
        let view = UITableView()
        view.register(MyGroupsTableViewCell.self, forCellReuseIdentifier: MyGroupsTableViewCell.cellID)
        view.tableFooterView = UIView()
        view.separatorStyle = .none
        if #available(iOS 15.0, *) { view.sectionHeaderTopPadding = 0 }
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    // TODO: - Collection View
    
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
private extension MyGroupsView {
    func setupUI() {
        backgroundColor = .white
        addSubview(tableview)
        configureUI()
    }
    
    func configureUI() {
        NSLayoutConstraint.activate([
            tableview.topAnchor.constraint(equalTo: topAnchor),
            tableview.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableview.trailingAnchor.constraint(equalTo: trailingAnchor),
            tableview.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}
