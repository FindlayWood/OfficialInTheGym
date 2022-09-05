//
//  MyWorkloadsView.swift
//  InTheGym
//
//  Created by Findlay Wood on 29/05/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit
//import Charts

class MyWorkloadsView: UIView {
    // MARK: - Properties
    
    // MARK: - Subviews
    lazy var collectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: generateCollectionLayout())
        view.register(MyWorkloadCollectionCell.self, forCellWithReuseIdentifier: MyWorkloadCollectionCell.reuseID)
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
private extension MyWorkloadsView {
    func setupUI() {
        backgroundColor = .secondarySystemBackground
        addSubview(collectionView)
        configureUI()
    }
    func configureUI() {
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    func generateCollectionLayout() -> UICollectionViewFlowLayout {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 16
        layout.itemSize = CGSize(width: Constants.screenSize.width - 16, height: 150)
        layout.sectionInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        layout.scrollDirection = .vertical
        return layout
    }
}
