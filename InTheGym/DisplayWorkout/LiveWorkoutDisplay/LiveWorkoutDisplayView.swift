//
//  LiveWorkoutDisplayView.swift
//  InTheGym
//
//  Created by Findlay Wood on 28/01/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
import UIKit

class LiveWorkoutDisplayView: UIView {
    
    // MARK: - Properties
    private let showClipsFrame = CGRect(x: 5, y: 0, width: Constants.screenSize.width - 10, height: 100)
    private let hideClipsFrame = CGRect(x: 5, y: 0, width: Constants.screenSize.width - 10, height: 0)
    
    private var tableviewTopAnchor: NSLayoutConstraint!
    
    var isClipShowing: Bool = false
    
    // MARK: - Subviews
    lazy var clipCollection: UICollectionView = {
        let collection = UICollectionView(frame: .zero, collectionViewLayout: generateClipCollectionLayout())
        collection.backgroundColor = .lightColour
        collection.register(DisplayClipCell.self, forCellWithReuseIdentifier: DisplayClipCell.reuseID)
        collection.showsHorizontalScrollIndicator = false
        collection.translatesAutoresizingMaskIntoConstraints = true
        return collection
    }()

    
    lazy var exerciseCollection: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: generateExerciseCollectionLayout())
        view.backgroundColor = .lightColour
        view.register(LiveExerciseCollectionCell.self, forCellWithReuseIdentifier: LiveExerciseCollectionCell.reuseID)
        view.register(LiveWorkoutPlusCollectionCell.self, forCellWithReuseIdentifier: LiveWorkoutPlusCollectionCell.reuseID)
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
private extension LiveWorkoutDisplayView {
    func setupUI() {
        backgroundColor = .lightColour
        addSubview(clipCollection)
        addSubview(exerciseCollection)
        constrainUI()
    }
    func constrainUI() {
        clipCollection.frame = hideClipsFrame
        tableviewTopAnchor = exerciseCollection.topAnchor.constraint(equalTo: topAnchor, constant: 0)
        NSLayoutConstraint.activate([
                                     tableviewTopAnchor,
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
        layout.minimumLineSpacing = 20
        layout.estimatedItemSize = CGSize(width: Constants.screenSize.width - 10, height: 360)
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.scrollDirection = .vertical
        return layout
    }
}

// MARK: - Public Configuration
extension LiveWorkoutDisplayView {
    public func showClipCollection() {
        isClipShowing = true
        tableviewTopAnchor.constant = 100
        UIView.animate(withDuration: 0.3) { [weak self] in
            guard let self = self else {return}
            self.clipCollection.frame = self.showClipsFrame
            self.layoutIfNeeded()
        }
    }
    public func hideClipCollection() {
        isClipShowing = false
        tableviewTopAnchor.constant = 0
        UIView.animate(withDuration: 0.3) { [weak self] in
            guard let self = self else {return}
            self.clipCollection.frame = self.hideClipsFrame
            self.layoutIfNeeded()
        }
    }
}
