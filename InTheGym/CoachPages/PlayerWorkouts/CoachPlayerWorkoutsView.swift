//
//  CoachPlayerWorkoutsView.swift
//  InTheGym
//
//  Created by Findlay Wood on 07/03/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit

class CoachPlayerWorkoutsView: UIView {
    // MARK: - Properties
    
    // MARK: - Subviews
    lazy var collectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: generateCollectionLayout())
        view.register(WorkoutCollectionViewCell.self, forCellWithReuseIdentifier: WorkoutCollectionViewCell.reuseID)
        view.backgroundColor = .lightColour
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var activityIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView()
        view.hidesWhenStopped = true
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
private extension CoachPlayerWorkoutsView {
    func setupUI() {
        addSubview(collectionView)
        addSubview(activityIndicator)
        configureUI()
    }
    
    func configureUI() {
        addFullConstraint(to: collectionView)
        addFullConstraint(to: activityIndicator)
    }
    
    func generateCollectionLayout() -> UICollectionViewFlowLayout {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
//        layout.minimumInteritemSpacing = 5
        layout.minimumLineSpacing = 8
        layout.itemSize = CGSize(width: Constants.screenSize.width - 16, height: 160)
        layout.sectionInset = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
        layout.scrollDirection = .vertical
        return layout
    }
}

// MARK: - Public
extension CoachPlayerWorkoutsView {
    public func setLoading(_ loading: Bool) {
        if loading {
            collectionView.isHidden = true
            activityIndicator.startAnimating()
        } else {
            collectionView.isHidden = false
            activityIndicator.stopAnimating()
        }
    }
}
