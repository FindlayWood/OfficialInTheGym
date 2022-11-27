//
//  SearchView.swift
//  InTheGym
//
//  Created by Findlay Wood on 15/12/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit

class SearchView: UIView {
    // MARK: - Properties
    
    // MARK: - Subviews
    var searchField: UISearchBar = {
        let view = UISearchBar()
        view.placeholder = "search usernames..."
        view.showsCancelButton = true
        view.searchBarStyle = .prominent
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
    
    var icon: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(systemName: "magnifyingglass", withConfiguration: UIImage.SymbolConfiguration(scale: .large))
        view.tintColor = .darkColour
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var emptyListLabel: UILabel = {
        let label = UILabel()
        label.text = "Search for other users by their usernames."
        label.backgroundColor = .clear
        label.font = .preferredFont(forTextStyle: .body, weight: .medium)
        label.textColor = .label
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    lazy var vstack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [icon, emptyListLabel])
        stack.axis = .vertical
        stack.spacing = 8
        stack.alignment = .center
        stack.distribution = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
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
private extension SearchView {
    func setupUI() {
        backgroundColor = .systemBackground
        addSubview(searchField)
        addSubview(tableview)
        addSubview(vstack)
        configureUI()
    }
    
    func configureUI() {
        NSLayoutConstraint.activate([
            searchField.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            searchField.leadingAnchor.constraint(equalTo: leadingAnchor),
            searchField.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            tableview.topAnchor.constraint(equalTo: searchField.bottomAnchor),
            tableview.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableview.trailingAnchor.constraint(equalTo: trailingAnchor),
            tableview.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            vstack.centerYAnchor.constraint(equalTo: tableview.centerYAnchor),
            vstack.centerXAnchor.constraint(equalTo: tableview.centerXAnchor),
            vstack.leadingAnchor.constraint(equalTo: tableview.leadingAnchor, constant: 16),
            vstack.trailingAnchor.constraint(equalTo: tableview.trailingAnchor, constant: -16)
        ])
    }
}
// MARK: - Public Configure
extension SearchView {
    func showEmpty(_ hidden: Bool) {
        vstack.isHidden = !hidden
    }
}
