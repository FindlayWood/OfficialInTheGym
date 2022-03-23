//
//  PostsChildView.swift
//  InTheGym
//
//  Created by Findlay Wood on 20/03/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit

class PostsChildView: UIView {
    
    // MARK: - Properties
    
    // MARK: - Subviews
    var tableview: UITableView = {
        let view = UITableView()
        view.rowHeight = UITableView.automaticDimension
        view.estimatedRowHeight = 90
        view.backgroundColor = Constants.darkColour
        view.register(PostTableViewCell.self, forCellReuseIdentifier: PostTableViewCell.cellID)
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
private extension PostsChildView {
    func setupUI() {
        addSubview(tableview)
        configureUI()
    }
    
    func configureUI() {
        addFullConstraint(to: tableview)
    }
}
