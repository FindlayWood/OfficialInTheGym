//
//  UsersChildView.swift
//  InTheGym
//
//  Created by Findlay Wood on 03/03/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit

class UsersChildView: UIView {
    // MARK: - Properties
    
    // MARK: - Subviews
    var tableview: UITableView = {
        let view = UITableView()
        view.register(UserTableViewCell.self, forCellReuseIdentifier: UserTableViewCell.cellID)
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
private extension UsersChildView {
    func setupUI() {
        backgroundColor = .white
        addSubview(tableview)
        configureUI()
    }
    func configureUI() {
        addFullConstraint(to: tableview)
    }
}
