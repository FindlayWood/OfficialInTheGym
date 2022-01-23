//
//  ExerciseCollectionCell.swift
//  InTheGym
//
//  Created by Findlay Wood on 22/01/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
import UIKit

class ExerciseCollectionCell: FullWidthCollectionViewCell {
    // MARK: - Properties
    static let reuseID = "ExerciseCollectionCell"
    
    // MARK: - Subviews
    var exerciseNameButton: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = UIFont(name: "Menlo-Bold", size: 29)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.titleLabel?.minimumScaleFactor = 0.2
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
private extension ExerciseCollectionCell {
    func setupUI() {
        backgroundColor = .offWhiteColour
        layer.cornerRadius = 10
        contentView.layer.cornerRadius = 10
        contentView.addSubview(exerciseNameButton)
        contentView.addSubview(topSeparatorView)
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
            topSeparatorView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
            
        ])
    }
}
// MARK: - Public Configuration
extension ExerciseCollectionCell {
    public func configure(with model: ExerciseModel) {
        exerciseNameButton.setTitle(model.exercise, for: .normal)
    }
}
