//
//  AddMoreToExerciseView.swift
//  InTheGym
//
//  Created by Findlay Wood on 21/08/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit

class AddMoreToExerciseView: UIView {
    // MARK: - Subviews
    var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 8
        layout.sectionInset = .init(top: 8, left: 8, bottom: 8, right: 8)
        layout.itemSize = CGSize(width: Constants.screenSize.width / 2 - 16, height: Constants.screenSize.width / 2)
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.backgroundColor = .secondarySystemBackground
        view.register(AddMoreCollectionCell.self, forCellWithReuseIdentifier: AddMoreCollectionCell.reuseID)
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
// MARK: - Setup UI
private extension AddMoreToExerciseView {
    func setupUI() {
        addSubview(collectionView)
        constrainUI()
    }
    func constrainUI() {
        NSLayoutConstraint.activate([collectionView.topAnchor.constraint(equalTo: topAnchor),
                                     collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
                                     collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
                                     collectionView.bottomAnchor.constraint(equalTo: bottomAnchor)])
    }
}
