//
//  ExerciseSelectionCell.swift
//  InTheGym
//
//  Created by Findlay Wood on 02/09/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit

class ExerciseSelectionCell: UICollectionViewCell {
    
    // MARK: - Properties
    private let viewDimension: CGFloat = 100
    private let imageViewDimension: CGFloat = 50
    
    static let reuseIdentifier = "ExerciseSelectionCellID"
    
    weak var delegate: UploadingCellActions?
    
    // MARK: - Subviews
    var label: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 25, weight: .bold)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        label.textColor = .black
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 3
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    lazy var circleViewOne: UIView = {
        let view = UIView()
        view.backgroundColor = .lightColour
        view.alpha = 0.6
        view.layer.cornerRadius = 50
        view.widthAnchor.constraint(equalToConstant: viewDimension).isActive = true
        view.heightAnchor.constraint(equalToConstant: viewDimension).isActive = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    lazy var circleViewTwo: UIView = {
        let view = UIView()
        view.backgroundColor = .lightColour
        view.alpha = 0.6
        view.layer.cornerRadius = 50
        view.widthAnchor.constraint(equalToConstant: viewDimension).isActive = true
        view.heightAnchor.constraint(equalToConstant: viewDimension).isActive = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

}

private extension ExerciseSelectionCell {
    func setupUI() {
        layer.cornerRadius = 10
        clipsToBounds = true
        backgroundColor = .offWhiteColour
        addSubview(circleViewOne)
        addSubview(circleViewTwo)
        addSubview(label)
        constrainUI()
    }
    func constrainUI() {
        NSLayoutConstraint.activate([
            circleViewOne.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 40),
            circleViewOne.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 20),
            circleViewTwo.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 10),
            circleViewTwo.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 50),
            
            label.topAnchor.constraint(equalTo: topAnchor, constant: 5),
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 5),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -5),
            
        ])
    }
}

extension ExerciseSelectionCell {
    func configure(with exercise: String) {
        label.text = exercise
    }
}
