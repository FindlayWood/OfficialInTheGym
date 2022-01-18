//
//  MainWorkoutTableViewCell.swift
//  InTheGym
//
//  Created by Findlay Wood on 17/01/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
import UIKit

class MainWorkoutTableViewCell: UITableViewCell {
    // MARK: - Properties
    static var cellID = "MainWorkoutTableViewCell"
    
    // MARK: - Subviews
    var exerciseNameButton: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = UIFont(name: "Menlo-Bold", size: 29)
        button.setTitleColor(.black, for: .normal)
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
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var repsLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Menlo", size: 18)
        label.textColor = .lightGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var bodyTypeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var collectionView: UICollectionView = {
        let view = UICollectionView()
        view.heightAnchor.constraint(equalToConstant: 169).isActive = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var bottomSeparatorView: UIView = {
        let view = UIView()
        view.heightAnchor.constraint(equalToConstant: 2).isActive = true
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
    
    // MARK: - Initializer
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        rpeButton.setTitle("RPE", for: .normal)
        rpeButton.setTitleColor( .systemBlue, for: .normal)
        repsLabel.text = nil
    }
    
}
// MARK: - Configure
private extension MainWorkoutTableViewCell {
    func setupUI() {
        backgroundColor = .lightColour
        contentView.addSubview(exerciseNameButton)
        contentView.addSubview(topSeparatorView)
        contentView.addSubview(setsLabel)
        contentView.addSubview(repsLabel)
        contentView.addSubview(bodyTypeLabel)
        contentView.addSubview(collectionView)
        contentView.addSubview(bottomSeparatorView)
        contentView.addSubview(noteButton)
        contentView.addSubview(clipButton)
        contentView.addSubview(rpeButton)
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
            setsLabel.heightAnchor.constraint(equalToConstant: 30),
            
            bodyTypeLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            bodyTypeLabel.topAnchor.constraint(equalTo: topSeparatorView.bottomAnchor, constant: 6),
            
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
            noteButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),
            
            clipButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            clipButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),
            
            rpeButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            rpeButton.topAnchor.constraint(equalTo: bottomSeparatorView.bottomAnchor, constant: 6)
            
        ])
    }
}

// MARK: - Public Configuration
extension MainWorkoutTableViewCell {
    public func configure(with model: ExerciseModel) {
        exerciseNameButton.setTitle(model.exercise, for: .normal)
        setsLabel.text = model.sets.description + " SETS"
        repsLabel.text = model.reps.repString()
        bodyTypeLabel.text = model.type.rawValue
        if let rpe = model.rpe {
            rpeButton.setTitle(rpe.description, for: .normal)
            rpeButton.setTitleColor(Constants.rpeColors[rpe - 1], for: .normal)
        }
    }
}
