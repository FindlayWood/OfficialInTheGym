//
//  DisplayNotificationsView.swift
//  InTheGym
//
//  Created by Findlay Wood on 14/03/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit

class DisplayNotificationsView: UIView {
    
    // MARK: - Properties
    
    // MARK: - Subviews
    var tableview: UITableView = {
        let view = UITableView()
        view.tableFooterView = UIView()
        view.separatorInset = .zero
        view.layoutMargins = .zero
        view.register(NotificationsTableViewCell.self, forCellReuseIdentifier: NotificationsTableViewCell.cellID)
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
private extension DisplayNotificationsView {
    func setupUI() {
        backgroundColor = .white
        addSubview(tableview)
        configureUI()
    }
    
    func configureUI() {
        addFullConstraint(to: tableview)
    }
}
