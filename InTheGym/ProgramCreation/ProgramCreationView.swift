//
//  ProgramCreationView.swift
//  InTheGym
//
//  Created by Findlay Wood on 20/02/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
import UIKit
import SkyFloatingLabelTextField

class ProgramCreationView: UIView {
    // MARK: - Properties
    
    // MARK: - Subviews
    var titleView: UIView = {
        let view = UIView()
        view.backgroundColor = .lightColour
        view.layer.cornerRadius = 8
        view.layer.borderColor = UIColor.black.cgColor
        view.layer.borderWidth = 2
        view.addViewShadow(with: .darkColour)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.text = "Title:"
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var workoutTitleField: SkyFloatingLabelTextField = {
        let field = SkyFloatingLabelTextField()
        field.tintColor = .white
        field.returnKeyType = .done
        field.textColor = .white
        field.placeholderColor = .lightGray
        field.selectedLineHeight = 4
        field.lineHeight = 2
        field.titleColor = .white
        field.lineColor = .white
        field.title = ""
        field.selectedTitle = ""
        field.selectedTitleColor = .white
        field.selectedLineColor = .white
        field.placeholder = "enter program title..."
        field.font = .systemFont(ofSize: 20, weight: .bold)
        field.clearButtonMode = .never
        field.autocapitalizationType = .words
        field.heightAnchor.constraint(equalToConstant: 45).isActive = true
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
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
        super.init(frame: frame)
        setupUI()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
}
// MARK: - Configure
private extension ProgramCreationView {
    func setupUI() {
        backgroundColor = .white
        titleView.addSubview(workoutTitleField)
        titleView.addSubview(titleLabel)
        addSubview(titleView)
        addSubview(weekLabel)
        addSubview(weeksCollectionView)
        addSubview(collectionView)
        configureUI()
    }
    
    func configureUI() {
        NSLayoutConstraint.activate([
            titleView.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            titleView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            titleView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            
            titleLabel.topAnchor.constraint(equalTo: titleView.topAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: titleView.leadingAnchor, constant: 8),
            
            workoutTitleField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: -4),
            workoutTitleField.leadingAnchor.constraint(equalTo: titleView.leadingAnchor, constant: 8),
            workoutTitleField.trailingAnchor.constraint(equalTo: titleView.trailingAnchor, constant: -8),
            workoutTitleField.bottomAnchor.constraint(equalTo: titleView.bottomAnchor, constant: -20),
            
            weeksCollectionView.topAnchor.constraint(equalTo: titleView.bottomAnchor, constant: 8),
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
extension ProgramCreationView {
    public func updateWeekLabel(to newWeek: Int) {
        weekLabel.text = "Week \(newWeek)"
    }
}
