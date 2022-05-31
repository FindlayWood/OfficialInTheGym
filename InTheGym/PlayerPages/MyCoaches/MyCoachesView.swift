//
//  MyCoachesView.swift
//  InTheGym
//
//  Created by Findlay Wood on 30/05/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit

class MyCoachesView: UIView {
    // MARK: - Properties
    
    // MARK: - Subviews
    var tableview: UITableView = {
        let view = UITableView()
        view.register(UserTableViewCell.self, forCellReuseIdentifier: UserTableViewCell.cellID)
        view.backgroundColor = .secondarySystemBackground
        view.tableFooterView = UIView()
        view.tableFooterView = UIView()
        view.separatorInset = .zero
        view.layoutMargins = .zero
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
private extension MyCoachesView {
    func setupUI() {
        addSubview(tableview)
        configureUI()
    }
    func configureUI() {
            NSLayoutConstraint.activate([
                tableview.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
                tableview.leadingAnchor.constraint(equalTo: leadingAnchor),
                tableview.trailingAnchor.constraint(equalTo: trailingAnchor),
                tableview.bottomAnchor.constraint(equalTo: bottomAnchor)
            ])
    }
}
