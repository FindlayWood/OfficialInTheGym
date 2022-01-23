//
//  SavedWorkoutDisplayView.swift
//  InTheGym
//
//  Created by Findlay Wood on 20/01/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
import UIKit

class SavedWorkoutDisplayView: UIView {
    
    // MARK: - Properties
    
    // MARK: - Subviews
    
    lazy var exerciseCollection: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: generateExerciseCollectionLayout())
        view.backgroundColor = .lightColour
        view.register(MainWorkoutExerciseCollectionCell.self, forCellWithReuseIdentifier: MainWorkoutExerciseCollectionCell.reuseID)
        view.register(MainWorkoutCircuitCollectionCell.self, forCellWithReuseIdentifier: MainWorkoutCircuitCollectionCell.reuseID)
        view.register(MainWorkoutAMRAPCollectionCell.self, forCellWithReuseIdentifier: MainWorkoutAMRAPCollectionCell.reuseID)
        view.register(MainWorkoutEMOMCollectionCell.self, forCellWithReuseIdentifier: MainWorkoutEMOMCollectionCell.reuseID)
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
// MARK: - Setup UI
private extension SavedWorkoutDisplayView {
    func setupUI() {
        backgroundColor = .lightColour
        addSubview(exerciseCollection)
        constrainUI()
    }
    func constrainUI() {
        NSLayoutConstraint.activate([
            exerciseCollection.topAnchor.constraint(equalTo: topAnchor, constant: 0),
            exerciseCollection.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 5),
            exerciseCollection.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -5),
            exerciseCollection.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
    }
    func generateExerciseCollectionLayout() -> UICollectionViewFlowLayout {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 20
        layout.itemSize = CGSize(width: Constants.screenSize.width - 10, height: 360)
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.scrollDirection = .vertical
        return layout
    }
}

// MARK: - Public Configuration
extension SavedWorkoutDisplayView {}
