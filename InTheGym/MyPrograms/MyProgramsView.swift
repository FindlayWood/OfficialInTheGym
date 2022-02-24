//
//  MyProgramsView.swift
//  InTheGym
//
//  Created by Findlay Wood on 22/02/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
import UIKit

class MyProgramsView: UIView {
    // MARK: - Properties
    
    // MARK: - Subviews
    var segmentControl: CustomisedSegmentControl = {
        let view = CustomisedSegmentControl(frame: .zero, buttonTitles: ["Current", "Saved", "Completed"])
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var collectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: generateCollectionLayout())
        view.register(ProgramCollectionCell.self, forCellWithReuseIdentifier: ProgramCollectionCell.reuseID)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var plusButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "bluePlus3"), for: .normal)
        button.widthAnchor.constraint(equalToConstant: 100).isActive = true
        button.heightAnchor.constraint(equalToConstant: 100).isActive = true
        button.addViewShadow(with: .darkColour)
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
private extension MyProgramsView {
    func setupUI() {
        backgroundColor = .white
        addSubview(segmentControl)
        addSubview(collectionView)
        addSubview(plusButton)
        plusButton.isHidden = true
        configureUI()
    }
    
    func configureUI() {
        NSLayoutConstraint.activate([
            segmentControl.topAnchor.constraint(equalTo: topAnchor),
            segmentControl.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            segmentControl.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            segmentControl.heightAnchor.constraint(equalToConstant: 50),
            
            collectionView.topAnchor.constraint(equalTo: segmentControl.bottomAnchor, constant: 16),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            plusButton.trailingAnchor.constraint(equalTo: collectionView.trailingAnchor, constant: -5),
            plusButton.bottomAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: -5)
        ])
    }
    
    func generateCollectionLayout() -> UICollectionViewFlowLayout {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 5
        layout.minimumLineSpacing = 8
        layout.itemSize = CGSize(width: Constants.screenSize.width / 2 - 16 , height: 200)
        layout.sectionInset = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
        layout.scrollDirection = .vertical
        return layout
    }
}

// MARK: - Public Configuration
extension MyProgramsView {
    public func setDisplay(to index: Int) {
        if index == 0 || index == 2 {
            plusButton.isHidden = true
        } else {
            plusButton.isHidden = false
        }
    }
}
