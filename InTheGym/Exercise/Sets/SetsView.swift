//
//  SetsView.swift
//  InTheGym
//
//  Created by Findlay Wood on 07/01/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
import UIKit

class SetsView: UIView {
    // MARK: - Properties
    
    // MARK: - Subviews
    //collection to display number options
    lazy var collection: UICollectionView = {
        let collection = UICollectionView(frame: .zero, collectionViewLayout: generateLayout())
        collection.backgroundColor = .white
        collection.register(SetsCell.self, forCellWithReuseIdentifier: SetsCell.cellID)
        collection.translatesAutoresizingMaskIntoConstraints = false
        return collection
    }()
    
    lazy var setLabel: UILabel = {
       let label = UILabel()
        label.text = "1"
        label.textColor = Constants.darkColour
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        label.font = .systemFont(ofSize: 200, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var plusButton: UIButton = {
       let button = UIButton()
        button.setTitle("+", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 120, weight: .bold)
        button.backgroundColor = .clear
        button.setTitleColor(.darkColour, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    lazy var minusButton: UIButton = {
       let button = UIButton()
        button.setTitle("-", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 120, weight: .bold)
        button.backgroundColor = .clear
        button.setTitleColor(Constants.darkColour, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
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
        label.textAlignment = .center
        label.textColor = Constants.darkColour
        label.font = UIFont(name: "Menlo-Bold", size: 20)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
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
    
    // MARK: - Functions
    func generateLayout() -> UICollectionViewFlowLayout {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 5
        layout.minimumLineSpacing = 5
        layout.itemSize = CGSize(width: 80, height: 80)
        layout.sectionInset = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
        layout.scrollDirection = .horizontal
        return layout
    }
    
}
// MARK: - Configure
private extension SetsView {
    func setupUI() {
        backgroundColor = .white
        addSubview(setLabel)
        addSubview(minusButton)
        addSubview(plusButton)
        addSubview(collection)
        addSubview(nextButton)
        addSubview(pageNumberLabel)
        configureUI()
    }
    
    func configureUI() {
        NSLayoutConstraint.activate([setLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
                                     setLabel.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -20),
                                     setLabel.leadingAnchor.constraint(equalTo: minusButton.trailingAnchor),
                                     setLabel.trailingAnchor.constraint(equalTo: plusButton.leadingAnchor),
                                     
                                     minusButton.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -20),
                                     minusButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
                                     minusButton.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.2),
                                     
                                     plusButton.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -20),
                                     plusButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
                                     plusButton.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.2),
        
                                     collection.leadingAnchor.constraint(equalTo: leadingAnchor),
                                     collection.trailingAnchor.constraint(equalTo: trailingAnchor),
                                     collection.topAnchor.constraint(equalTo: setLabel.bottomAnchor, constant: 10),
                                     collection.heightAnchor.constraint(equalToConstant: 100),
        
                                     nextButton.topAnchor.constraint(equalTo: collection.bottomAnchor, constant: 10),
                                     nextButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
                                     nextButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
                                     nextButton.heightAnchor.constraint(equalToConstant: 45),
        
                                     pageNumberLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
                                     pageNumberLabel.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}
