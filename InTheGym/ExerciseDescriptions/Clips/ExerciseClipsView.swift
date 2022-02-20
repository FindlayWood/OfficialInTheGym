//
//  ExerciseClipsView.swift
//  InTheGym
//
//  Created by Findlay Wood on 17/02/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
import UIKit

class ExerciseClipsView: UIView {
    // MARK: - Properties
    
    // MARK: - Subviews
    lazy var collectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: generateCollectionLayout())
        view.register(ExerciseClipsCollectionCell.self, forCellWithReuseIdentifier: ExerciseClipsCollectionCell.reuseID)
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var plusButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "bluePlus3"), for: .normal)
        button.widthAnchor.constraint(equalToConstant: 100).isActive = true
        button.heightAnchor.constraint(equalToConstant: 100).isActive = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
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
private extension ExerciseClipsView {
    func setupUI() {
        addSubview(collectionView)
        addSubview(plusButton)
        backgroundColor = .white
        configureUI()
    }
    
    func configureUI() {
        addFullConstraint(to: collectionView)
        NSLayoutConstraint.activate([
            plusButton.trailingAnchor.constraint(equalTo: collectionView.trailingAnchor, constant: -5),
            plusButton.bottomAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: -5)
        ])
    }
    func generateCollectionLayout() -> UICollectionViewFlowLayout {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 16
        layout.estimatedItemSize = CGSize(width: Constants.screenSize.width / 2 - 16, height: Constants.screenSize.width / 2)
        layout.sectionInset = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
        layout.scrollDirection = .vertical
        return layout
    }
}
