//
//  SavedWorkoutBottomChildView.swift
//  InTheGym
//
//  Created by Findlay Wood on 07/03/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
import UIKit

class SavedWorkoutBottomChildView: UIView {
    // MARK: - Properties
    
    // MARK: - Subviews
    var scrollIndicatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .darkGray
        view.heightAnchor.constraint(equalToConstant: 6).isActive = true
        view.layer.cornerRadius = 3
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var optionsButton: UIButton = {
        let label = UIButton()
        label.titleLabel?.font = UIFont(name: "Menlo-Bold", size: 25)
        label.setTitleColor(.darkColour, for: .normal)
        label.setTitle("OPTIONS", for: .normal)
        label.contentHorizontalAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    lazy var collectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: generateCollectionLayout())
        view.register(OptionsCell.self, forCellWithReuseIdentifier: OptionsCell.reuseID)
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
private extension SavedWorkoutBottomChildView {
    func setupUI() {
        backgroundColor = .systemBackground
        layer.cornerRadius = 8
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        addViewTopShadow(with: .black)
        addSubview(scrollIndicatorView)
        addSubview(optionsButton)
        addSubview(collectionView)
        configureUI()
    }
    func configureUI() {
        NSLayoutConstraint.activate([
            scrollIndicatorView.topAnchor.constraint(equalTo: topAnchor, constant: 4),
            scrollIndicatorView.centerXAnchor.constraint(equalTo: centerXAnchor),
            scrollIndicatorView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.25),
            
            optionsButton.topAnchor.constraint(equalTo: scrollIndicatorView.bottomAnchor, constant: 8),
            optionsButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            optionsButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            
            collectionView.topAnchor.constraint(equalTo: topAnchor, constant: Constants.screenSize.height * 0.075),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor)
            
        ])
    }
    func generateCollectionLayout() -> UICollectionViewFlowLayout {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 8
        layout.itemSize = CGSize(width: Constants.screenSize.width - 16, height: 60)
        layout.sectionInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        layout.scrollDirection = .vertical
        return layout
    }
}
