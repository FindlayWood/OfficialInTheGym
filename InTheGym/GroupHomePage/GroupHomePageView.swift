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
        if #available(iOS 15.0, *) {
            view.sectionHeaderTopPadding = 0
        }
//        view.register(UINib(nibName: "TimelinePostTableViewCell", bundle: nil), forCellReuseIdentifier: "TimelinePostTableViewCell")
//        view.register(UINib(nibName: "TimelineCreatedWorkoutTableViewCell", bundle: nil), forCellReuseIdentifier: "TimelineCreatedWorkoutTableViewCell")
//        view.register(UINib(nibName: "TimelineCompletedWorkoutTableViewCell", bundle: nil), forCellReuseIdentifier: "TimelineCompletedTableViewCell")
//        view.register(UINib(nibName: "TimelineActivityTableViewCell", bundle: nil), forCellReuseIdentifier: "TimelineActivityTableViewCell")
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var headerView: StretchyTableHeaderView = {
        let view = StretchyTableHeaderView(frame: CGRect(x: 0, y: 0, width: Constants.screenSize.width, height: 150))
        view.imageView.backgroundColor = .lightGray
        return view
    }()

    
    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
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
        NSLayoutConstraint.activate([tableview.topAnchor.constraint(equalTo: topAnchor),
                                     tableview.leadingAnchor.constraint(equalTo: leadingAnchor),
                                     tableview.trailingAnchor.constraint(equalTo: trailingAnchor),
                                     tableview.bottomAnchor.constraint(equalTo: bottomAnchor)])
    }
}
