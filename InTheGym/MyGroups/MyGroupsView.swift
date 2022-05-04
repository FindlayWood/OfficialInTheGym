//
//  MyGroupsView.swift
//  InTheGym
//
//  Created by Findlay Wood on 31/12/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import UIKit

class MyGroupsView: UIView {
    // MARK: - Properties
    
    // MARK: - Subviews
    var tableview: UITableView = {
        let view = UITableView()
        view.register(MyGroupsTableViewCell.self, forCellReuseIdentifier: MyGroupsTableViewCell.cellID)
        view.tableFooterView = UIView()
        view.separatorStyle = .none
        if #available(iOS 15.0, *) { view.sectionHeaderTopPadding = 0 }
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    // TODO: - Collection View
    lazy var collectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: generateCollectionLayout())
        view.register(MyGroupsCollectionViewCell.self, forCellWithReuseIdentifier: MyGroupsCollectionViewCell.reuseID)
        view.backgroundColor = .systemBackground
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: UIScreen.main.bounds)
        setupUI()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
}
// MARK: - Configure
private extension MyGroupsView {
    func setupUI() {
        backgroundColor = .systemBackground
        addSubview(collectionView)
        configureUI()
    }
    
    func configureUI() {
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    func generateCollectionLayout() -> UICollectionViewFlowLayout {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 8
        layout.itemSize = CGSize(width: (Constants.screenSize.width / 2) - 16 , height: 250)
        layout.sectionInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        layout.scrollDirection = .vertical
        return layout
    }
}
