//
//  DisplayWorkoutsCollectionHeader.swift
//  InTheGym
//
//  Created by Findlay Wood on 24/05/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit

class DisplayWorkoutsCollectionHeader: UICollectionReusableView {
    
    // MARK: - Publishers
    
    // MARK: - Properties
    static let reuseIdentifier = "DisplayWorkoutsCollectionHeaderreuseID"
    static let elementID = "headerElement"
    
    // MARK: - Subviews
    var searchField: UISearchBar = {
        let view = UISearchBar()
        view.placeholder = "search workouts..."
        view.showsCancelButton = true
        view.searchBarStyle = .prominent
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

// MARK: - Setup UI
private extension DisplayWorkoutsCollectionHeader {
    func setupUI() {
        backgroundColor = .systemBackground
        addSubview(searchField)
        constrainUI()
    }
    func constrainUI() {
        NSLayoutConstraint.activate([
            searchField.topAnchor.constraint(equalTo: topAnchor),
            searchField.leadingAnchor.constraint(equalTo: leadingAnchor),
            searchField.trailingAnchor.constraint(equalTo: trailingAnchor),
            searchField.heightAnchor.constraint(equalToConstant: 48),
            searchField.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

}

