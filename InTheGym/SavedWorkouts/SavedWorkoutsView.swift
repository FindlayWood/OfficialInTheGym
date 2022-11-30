//
//  SavedWorkoutsView.swift
//  InTheGym
//
//  Created by Findlay Wood on 15/01/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit

class SavedWorkoutsView: UIView {
    // MARK: - Properties
    
    // MARK: - Subviews
    var tableview: UITableView = {
        let view = UITableView()
        view.tableFooterView = UIView()
        if #available(iOS 15.0, *) { view.sectionHeaderTopPadding = 0 }
        view.register(SavedWorkoutTableViewCell.self, forCellReuseIdentifier: SavedWorkoutTableViewCell.cellID)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    lazy var collectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: generateCollectionLayout())
        view.register(SavedWorkoutCollectionCell.self, forCellWithReuseIdentifier: SavedWorkoutCollectionCell.reuseID)
        view.backgroundColor = .systemBackground
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
private extension SavedWorkoutsView {
    func setupUI() {
        backgroundColor = .lightColour
        addSubview(collectionView)
        configureUI()
    }
    
    func configureUI() {
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
    }
    func generateCollectionLayout() -> UICollectionViewFlowLayout {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 5
        layout.minimumLineSpacing = 10
        layout.estimatedItemSize = CGSize(width: Constants.screenSize.width - 20, height: 160)
        layout.sectionInset = UIEdgeInsets(top: 5, left: 10, bottom: 0, right: 10)
        layout.scrollDirection = .vertical
        return layout
    }
}
