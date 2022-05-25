//
//  BaseExerciseCollectionCell.swift
//  InTheGym
//
//  Created by Findlay Wood on 28/01/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
import UIKit
import Combine

class BaseExerciseCollectionCell: FullWidthCollectionViewCell {
    
    // MARK: - Publishers
    var completedAt: PassthroughSubject<IndexPath,Never> = PassthroughSubject<IndexPath,Never>()
    //var actionPublisher = PassthroughSubject<ExerciseAction,Never>()
    
    // MARK: - Properties
    //static var reuseID = "MainWorkoutExerciseCollectionCell"
    //var dataSource: WorkoutCollectionDataSource!
    var subscriptions = Set<AnyCancellable>()

    
    // MARK: - Subviews
    var exerciseNameButton: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = UIFont(name: "Menlo-Bold", size: 29)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.titleLabel?.minimumScaleFactor = 0.2
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    var topSeparatorView: UIView = {
        let view = UIView()
        view.heightAnchor.constraint(equalToConstant: 1).isActive = true
        view.backgroundColor = .black
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var setsLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Menlo-Bold", size: 22)
        label.textColor = .black
        label.heightAnchor.constraint(equalToConstant: 25).isActive = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var repsLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Menlo", size: 18)
        label.textColor = .lightGray
        label.heightAnchor.constraint(equalToConstant: 21).isActive = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var bodyTypeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.textColor = .black
        label.heightAnchor.constraint(equalToConstant: 24).isActive = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var collectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: generateCollectionLayout())
        view.register(MainWorkoutCollectionCell.self, forCellWithReuseIdentifier: MainWorkoutCollectionCell.reuseID)
        view.backgroundColor = .offWhiteColour
        view.heightAnchor.constraint(equalToConstant: 169).isActive = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var bottomSeparatorView: UIView = {
        let view = UIView()
        view.heightAnchor.constraint(equalToConstant: 1).isActive = true
        view.backgroundColor = .black
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var noteButton: UIButton = {
        let button = UIButton()
        button.setTitle("NOTES", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.titleLabel?.font = UIFont(name: "Menlo-Bold", size: 22)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    var clipButton: UIButton = {
        let button = UIButton()
        button.tintColor = .darkColour
        button.setImage(UIImage(systemName: "camera.fill"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    var rpeButton: UIButton = {
        let button = UIButton()
        button.setTitle("RPE", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.titleLabel?.font = UIFont(name: "Menlo-Bold", size: 22)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    
}
// MARK: - Configure
extension BaseExerciseCollectionCell {
    func setupUI() {
        backgroundColor = .offWhiteColour
        layer.cornerRadius = 10
        contentView.layer.cornerRadius = 10
        contentView.addSubview(exerciseNameButton)
        contentView.addSubview(topSeparatorView)
        contentView.addSubview(setsLabel)
        contentView.addSubview(repsLabel)
        contentView.addSubview(collectionView)
        contentView.addSubview(bottomSeparatorView)
        contentView.addSubview(noteButton)
        contentView.addSubview(clipButton)
        contentView.addSubview(rpeButton)
        contentView.addSubview(bodyTypeLabel)
        configureUI()
    }
    
    func configureUI() {
        NSLayoutConstraint.activate([
            exerciseNameButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            exerciseNameButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            exerciseNameButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            
            topSeparatorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5),
            topSeparatorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -5),
            topSeparatorView.topAnchor.constraint(equalTo: exerciseNameButton.bottomAnchor, constant: 6),
            
            setsLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            setsLabel.topAnchor.constraint(equalTo: topSeparatorView.bottomAnchor, constant: 6),

            repsLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            repsLabel.topAnchor.constraint(equalTo: setsLabel.bottomAnchor, constant: 4),

            collectionView.topAnchor.constraint(equalTo: repsLabel.bottomAnchor, constant: 10),
            collectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),

            bottomSeparatorView.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: 10),
            bottomSeparatorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5),
            bottomSeparatorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -5),

            noteButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            noteButton.topAnchor.constraint(equalTo: bottomSeparatorView.bottomAnchor, constant: 6),
            noteButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),

            clipButton.centerYAnchor.constraint(equalTo: noteButton.centerYAnchor),
            clipButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),

            rpeButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            rpeButton.topAnchor.constraint(equalTo: bottomSeparatorView.bottomAnchor, constant: 6),
            rpeButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),

            bodyTypeLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            bodyTypeLabel.topAnchor.constraint(equalTo: topSeparatorView.bottomAnchor, constant: 6),
            
        ])
    }
    func generateCollectionLayout() -> UICollectionViewFlowLayout {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 5
        layout.minimumLineSpacing = 10
        layout.itemSize = CGSize(width: 128, height: 150)
        layout.sectionInset = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
        layout.scrollDirection = .horizontal
        return layout
    }
}

// MARK: - Public Configuration
extension BaseExerciseCollectionCell {
//    public func configure(with model: ExerciseModel) {
//        exerciseNameButton.setTitle(model.exercise, for: .normal)
//        setsLabel.text = model.sets.description + " SETS"
//        repsLabel.text = model.reps.repString()
//        bodyTypeLabel.text = model.type.rawValue
//        if let rpe = model.rpe {
//            rpeButton.setTitle(rpe.description, for: .normal)
//            rpeButton.setTitleColor(Constants.rpeColors[rpe - 1], for: .normal)
//        }
//        dataSource = .init(collectionView: collectionView, isUserInteractionEnabled: userInteraction)
//        dataSource.updateTable(with: model.getSets())
//        dataSource.completeButtonTapped
//            .sink { [weak self] in self?.actionPublisher.send(.completed($0)) }
//            .store(in: &subscriptions)
//    }
//    public func setUserInteraction(to enabled: Bool) {
//        self.rpeButton.isUserInteractionEnabled = enabled
//        self.clipButton.isUserInteractionEnabled = enabled
//    }
}
