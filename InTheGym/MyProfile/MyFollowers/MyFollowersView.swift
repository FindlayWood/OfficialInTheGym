//
//  MyFollowersView.swift
//  InTheGym
//
//  Created by Findlay Wood on 16/05/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit

class MyFollowersView: UIView {
    // MARK: - Properties
    
    // MARK: - Subviews
    var segment: CustomUnderlineSegmentControl = {
        let view = CustomUnderlineSegmentControl(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 48), buttonTitles: ["Followers","Following"])
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var tableview: UITableView = {
        let view = UITableView()
        view.register(UserTableViewCell.self, forCellReuseIdentifier: UserTableViewCell.cellID)
        view.tableFooterView = UIView()
        view.backgroundColor = .secondarySystemBackground
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
private extension MyFollowersView {
    func setupUI() {
        backgroundColor = .systemBackground
        addSubview(segment)
        addSubview(tableview)
        configureUI()
    }
    
    func configureUI() {
        NSLayoutConstraint.activate([
            segment.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            segment.leadingAnchor.constraint(equalTo: leadingAnchor),
            segment.trailingAnchor.constraint(equalTo: trailingAnchor),
            segment.heightAnchor.constraint(equalToConstant: 48),
            
            tableview.topAnchor.constraint(equalTo: segment.bottomAnchor),
            tableview.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableview.trailingAnchor.constraint(equalTo: trailingAnchor),
            tableview.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}
