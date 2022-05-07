//
//  GroupHomePageView.swift
//  InTheGym
//
//  Created by Findlay Wood on 12/08/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import UIKit

class GroupHomePageView: UIView {
    
    // MARK: - Subviews
    lazy var tableview: UITableView = {
        let view = UITableView()
        view.tableFooterView = UIView()
        view.tableHeaderView = headerView
        view.register(GroupHomePageInfoTableViewCell.self, forCellReuseIdentifier: GroupHomePageInfoTableViewCell.cellID)
        view.register(LoadingTableViewCell.self, forCellReuseIdentifier: LoadingTableViewCell.cellID)
        view.register(UserTableViewCell.self, forCellReuseIdentifier: UserTableViewCell.cellID)
        view.register(PostTableViewCell.self, forCellReuseIdentifier: PostTableViewCell.cellID)
        if #available(iOS 15.0, *) { view.sectionHeaderTopPadding = 0 }
        view.separatorInset = .zero
        view.layoutMargins = .zero
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var headerView: StretchyTableHeaderView = {
        let view = StretchyTableHeaderView(frame: CGRect(x: 0, y: 0, width: Constants.screenSize.width, height: 150))
        view.imageView.backgroundColor = .lightGray
        return view
    }()
    var barView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        view.clipsToBounds = true
        view.layer.cornerRadius = 15
        return view
    }()
    var navBarView: UIImageView = {
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 15
        imageView.clipsToBounds = true
        imageView.layer.masksToBounds = false
        imageView.alpha = 0.0
        imageView.translatesAutoresizingMaskIntoConstraints = true
        return imageView
    }()
    
    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: UIScreen.main.bounds)
        setUpUI()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

// MARK: - Setup
private extension GroupHomePageView {
    func setUpUI() {
        addSubview(tableview)
        constrainUI()
    }
    func constrainUI() {
        NSLayoutConstraint.activate([tableview.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
                                     tableview.leadingAnchor.constraint(equalTo: leadingAnchor),
                                     tableview.trailingAnchor.constraint(equalTo: trailingAnchor),
                                     tableview.bottomAnchor.constraint(equalTo: bottomAnchor)])
    }
}
