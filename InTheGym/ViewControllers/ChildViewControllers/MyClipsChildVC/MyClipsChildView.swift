//
//  MyClipsChildView.swift
//  InTheGym
//
//  Created by Findlay Wood on 21/03/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit

class MyClipsChildView: UIView {
    // MARK: - Properties
    
    // MARK: - Subviews
    lazy var collectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: generateCollectionLayout())
        view.register(ExerciseClipsCollectionCell.self, forCellWithReuseIdentifier: ExerciseClipsCollectionCell.reuseID)
        view.backgroundColor = .white
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
private extension MyClipsChildView {
    func setupUI() {
        addSubview(collectionView)
        backgroundColor = .white
        configureUI()
    }
    
    func configureUI() {
        addFullConstraint(to: collectionView)
    }
    func generateCollectionLayout() -> UICollectionViewFlowLayout {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 16
        layout.itemSize = CGSize(width: Constants.screenSize.width / 2 - 16, height: Constants.screenSize.width / 2)
        layout.sectionInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        layout.scrollDirection = .vertical
        return layout
    }
}
