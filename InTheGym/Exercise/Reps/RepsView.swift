//
//  RepsView.swift
//  InTheGym
//
//  Created by Findlay Wood on 19/05/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import UIKit

class RepsView: UIView {
    
    // MARK: - Subviews
    lazy var topCollection: UICollectionView = {
        let collection = UICollectionView(frame: .zero, collectionViewLayout: generateTopLayout())
        collection.backgroundColor = .white
        collection.register(RepsCell.self, forCellWithReuseIdentifier: RepsCell.cellID)
        collection.translatesAutoresizingMaskIntoConstraints = false
        return collection
    }()
    
    var minusButton: UIButton = {
       let button = UIButton()
        button.setTitle("-", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 120, weight: .bold)
        button.backgroundColor = .clear
        button.setTitleColor(Constants.darkColour, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    var repLabel: UILabel = {
       let label = UILabel()
        label.textColor = Constants.darkColour
        label.font = .systemFont(ofSize: 200, weight: .bold)
        label.textAlignment = .center
        label.text = "1"
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var plusButton: UIButton = {
       let button = UIButton()
        button.setTitle("+", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 120, weight: .bold)
        button.backgroundColor = .clear
        button.setTitleColor(Constants.darkColour, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    lazy var bottomCollection: UICollectionView = {
        let collection = UICollectionView(frame: .zero, collectionViewLayout: generateBottomLayout())
        collection.backgroundColor = .white
        collection.register(SetsCell.self, forCellWithReuseIdentifier: SetsCell.cellID)
        collection.translatesAutoresizingMaskIntoConstraints = false
        return collection
    }()
    
    lazy var nextButton: UIButton = {
        let button = UIButton()
        button.setTitle("NEXT", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 24, weight: .bold)
        button.backgroundColor = Constants.darkColour
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.white.cgColor
        button.layer.cornerRadius = 22.5
        button.isHidden = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    lazy var pageNumberLabel: UILabel = {
        let label = UILabel()
        label.text = "4 of 6"
        label.textAlignment = .center
        label.textColor = Constants.darkColour
        label.font = UIFont(name: "Menlo-Bold", size: 20)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError()
    }
    
    // MARK: - Layout Functions
    func generateTopLayout() -> UICollectionViewFlowLayout {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 5
        layout.minimumLineSpacing = 5
        layout.itemSize = CGSize(width: 160, height: 120)
        layout.sectionInset = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
        layout.scrollDirection = .horizontal
        return layout
    }
    
    func generateBottomLayout() -> UICollectionViewFlowLayout {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 5
        layout.minimumLineSpacing = 5
        layout.itemSize = CGSize(width: 80, height: 80)
        layout.sectionInset = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
        layout.scrollDirection = .horizontal
        return layout
    }
}

// MARK: - Setup UI
private extension RepsView {
    func setupView() {
        backgroundColor = .white
        addSubview(topCollection)
        addSubview(minusButton)
        addSubview(repLabel)
        addSubview(plusButton)
        addSubview(bottomCollection)
        addSubview(nextButton)
        addSubview(pageNumberLabel)
        constrain()
    }
    
    func constrain() {
        NSLayoutConstraint.activate([topCollection.topAnchor.constraint(equalTo: topAnchor),
                                     topCollection.leadingAnchor.constraint(equalTo: leadingAnchor),
                                     topCollection.trailingAnchor.constraint(equalTo: trailingAnchor),
                                     topCollection.heightAnchor.constraint(equalToConstant: 130),
                                     
                                     minusButton.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -50),
                                     minusButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
                                     minusButton.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.2),
                                     
                                     repLabel.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -50),
                                     repLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
                                     repLabel.leadingAnchor.constraint(equalTo: minusButton.trailingAnchor),
                                     repLabel.trailingAnchor.constraint(equalTo: plusButton.leadingAnchor),
                                     
                                     plusButton.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -50),
                                     plusButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
                                     plusButton.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.2),
                                     
                                     bottomCollection.topAnchor.constraint(equalTo: repLabel.bottomAnchor, constant: 20),
                                     bottomCollection.leadingAnchor.constraint(equalTo: leadingAnchor),
                                     bottomCollection.trailingAnchor.constraint(equalTo: trailingAnchor),
                                     bottomCollection.heightAnchor.constraint(equalToConstant: 100),
                                     
                                     nextButton.topAnchor.constraint(equalTo: bottomCollection.bottomAnchor, constant: 20),
                                     nextButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
                                     nextButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
                                     nextButton.heightAnchor.constraint(equalToConstant: 45),
                                     
                                     pageNumberLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
                                     pageNumberLabel.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
    }
}
