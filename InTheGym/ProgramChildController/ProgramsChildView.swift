//
//  ProgramsChildView.swift
//  InTheGym
//
//  Created by Findlay Wood on 23/02/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit

class ProgramsChildView: UIView {

    // MARK: - Properties
    
    // MARK: - Subviews
    var weekLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 25, weight: .bold)
        label.textColor = .darkColour
        label.text = "Week 1"
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    lazy var weeksCollectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: generateWeekCollectionLayout())
        view.register(NumberCircleCollectionCell.self, forCellWithReuseIdentifier: NumberCircleCollectionCell.reuseID)
        view.register(LiveWorkoutPlusCollectionCell.self, forCellWithReuseIdentifier: LiveWorkoutPlusCollectionCell.reuseID)
        view.backgroundColor = .clear
        view.clipsToBounds = false
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    lazy var collectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: generateWorkoutCollectionLayout())
        view.register(SavedWorkoutCollectionCell.self, forCellWithReuseIdentifier: SavedWorkoutCollectionCell.reuseID)
        view.register(WorkoutCollectionViewCell.self, forCellWithReuseIdentifier: WorkoutCollectionViewCell.reuseID)
        view.register(LiveWorkoutPlusCollectionCell.self, forCellWithReuseIdentifier: LiveWorkoutPlusCollectionCell.reuseID)
        view.register(ProgramCreationWorkoutsHeaderView.self, forSupplementaryViewOfKind: ProgramCreationWorkoutsHeaderView.elementID, withReuseIdentifier: ProgramCreationWorkoutsHeaderView.reuseID)
        view.backgroundColor = .lightColour
        view.layer.cornerRadius = 8
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
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
// MARK: - Configure
private extension ProgramsChildView {
    func setupUI() {
        backgroundColor = .white
        addSubview(weekLabel)
        addSubview(weeksCollectionView)
        addSubview(collectionView)
        configureUI()
    }
    
    func configureUI() {
        NSLayoutConstraint.activate([
            weeksCollectionView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 8),
            weeksCollectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            weeksCollectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            weeksCollectionView.heightAnchor.constraint(equalToConstant: 100),
            
            weekLabel.topAnchor.constraint(equalTo: weeksCollectionView.bottomAnchor, constant: 8),
            weekLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            weekLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            collectionView.topAnchor.constraint(equalTo: weekLabel.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    func generateWorkoutCollectionLayout() -> UICollectionViewFlowLayout {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 5
        layout.minimumLineSpacing = 10
        layout.estimatedItemSize = CGSize(width: Constants.screenSize.width - 20, height: 160)
        layout.sectionInset = UIEdgeInsets(top: 5, left: 10, bottom: 0, right: 10)
        layout.scrollDirection = .vertical
        return layout
    }
    func generateWeekCollectionLayout() -> UICollectionViewFlowLayout {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 5
        layout.minimumLineSpacing = 5
        layout.itemSize = CGSize(width: 80, height: 80)
        layout.sectionInset = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
        layout.scrollDirection = .horizontal
        return layout
    }
}

// MARK: - Public Configuration
extension ProgramsChildView {
    public func updateWeekLabel(to newWeek: Int) {
        weekLabel.text = "Week \(newWeek)"
    }
}
