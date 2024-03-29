//
//  WorkoutChildView.swift
//  InTheGym
//
//  Created by Findlay Wood on 07/03/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit

class WorkoutChildView: UIView {
    
    // MARK: - Properties
    
    private var clipTopAnchor: NSLayoutConstraint!
    private var clipHeightAnchor: NSLayoutConstraint!
    
    var isClipShowing: Bool = false
    
    // MARK: - Subviews
    lazy var clipCollection: UICollectionView = {
        let collection = UICollectionView(frame: .zero, collectionViewLayout: generateClipCollectionLayout())
        collection.register(DisplayClipCell.self, forCellWithReuseIdentifier: DisplayClipCell.reuseID)
        collection.showsHorizontalScrollIndicator = false
        collection.backgroundColor = .lightColour
        collection.translatesAutoresizingMaskIntoConstraints = false
        return collection
    }()
    
    lazy var exerciseCollection: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: generateExerciseCollectionLayout())
        view.backgroundColor = .lightColour
        view.register(ExerciseCollectionCell.self, forCellWithReuseIdentifier: ExerciseCollectionCell.reuseID)
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
private extension WorkoutChildView {
    func setupUI() {
        backgroundColor = .lightColour
        addSubview(clipCollection)
        addSubview(exerciseCollection)
        constrainUI()
    }
    func constrainUI() {
        clipTopAnchor = exerciseCollection.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 0)
        clipHeightAnchor = clipCollection.heightAnchor.constraint(equalToConstant: 0)
        NSLayoutConstraint.activate([
            clipHeightAnchor,
            clipCollection.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            clipCollection.leadingAnchor.constraint(equalTo: leadingAnchor),
            clipCollection.trailingAnchor.constraint(equalTo: trailingAnchor),
            clipTopAnchor,
            exerciseCollection.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 5),
            exerciseCollection.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -5),
            exerciseCollection.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
    }
    func generateClipCollectionLayout() -> UICollectionViewFlowLayout {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 5
        layout.minimumLineSpacing = 5
        layout.itemSize = CGSize(width: 80, height: 80)
        layout.sectionInset = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
        layout.scrollDirection = .horizontal
        return layout
    }
    func generateExerciseCollectionLayout() -> UICollectionViewFlowLayout {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 5
        layout.minimumLineSpacing = 20
        layout.estimatedItemSize = CGSize(width: Constants.screenSize.width - 10, height: 360)
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.scrollDirection = .vertical
        return layout
    }
}

// MARK: - Public Configuration
extension WorkoutChildView {
    public func showClipCollection() {
        isClipShowing = true
        clipTopAnchor.constant = 100
        clipHeightAnchor.constant = 100
        UIView.animate(withDuration: 0.3) { [weak self] in
            guard let self = self else {return}
            self.layoutIfNeeded()
        }
    }
    public func hideClipCollection() {
        isClipShowing = false
        clipTopAnchor.constant = 0
        clipHeightAnchor.constant = 0
        UIView.animate(withDuration: 0.3) { [weak self] in
            guard let self = self else {return}
            self.layoutIfNeeded()
        }
    }
    
}
