//
//  DiscoverMoreTagsView.swift
//  InTheGym
//
//  Created by Findlay Wood on 26/05/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit

import UIKit

class DiscoverMoreTagsView: UIView {
    // MARK: - Properties
    
    // MARK: - Subviews
    var searchField: UISearchBar = {
        let view = UISearchBar()
        view.placeholder = "search tags..."
        view.showsCancelButton = true
        view.searchBarStyle = .prominent
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    lazy var collectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: generateCollectionLayout())
        view.register(TagAndExerciseCell.self, forCellWithReuseIdentifier: TagAndExerciseCell.reuseID)
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
private extension DiscoverMoreTagsView {
    func setupUI() {
        addSubview(searchField)
        addSubview(collectionView)
        configureUI()
    }
    func configureUI() {
        NSLayoutConstraint.activate([
            searchField.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            searchField.leadingAnchor.constraint(equalTo: leadingAnchor),
            searchField.trailingAnchor.constraint(equalTo: trailingAnchor),
            searchField.heightAnchor.constraint(equalToConstant: 48),
            collectionView.topAnchor.constraint(equalTo: searchField.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    func generateCollectionLayout() -> UICollectionViewFlowLayout {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 16
        layout.itemSize = CGSize(width: Constants.screenSize.width - 16, height: 65)
        layout.sectionInset = UIEdgeInsets(top: 8, left: 8, bottom: 0, right: 8)
        layout.scrollDirection = .vertical
        return layout
    }
}
