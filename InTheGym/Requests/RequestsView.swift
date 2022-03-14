//
//  RequestsView.swift
//  InTheGym
//
//  Created by Findlay Wood on 11/03/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit

class RequestsView: UIView {
    
    // MARK: - Properties
    
    // MARK: - Subviews
    var tableview: UITableView = {
        let view = UITableView()
        view.tableFooterView = UIView()
        view.register(RequestTableViewCell.self, forCellReuseIdentifier: RequestTableViewCell.cellID)
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
private extension RequestsView {
    func setupUI() {
        addSubview(tableview)
        configureUI()
    }
    
    func configureUI() {
        addFullConstraint(to: tableview)
    }
}
