//
//  MainWorkoutEMOMCollectionCell.swift
//  InTheGym
//
//  Created by Findlay Wood on 18/01/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
import UIKit

/// this class creates the cell to be displayed for an EMOM
class MainWorkoutEMOMCollectionCell: FullWidthCollectionViewCell {
    
    // MARK: - Properties
    static let reuseID = "MainWorkoutEMOMCollectionCell"
    
    // MARK: - Subviews
    var emomLabel: UILabel = {
        let label = UILabel()
        label.text = "EMOM"
        label.font = Constants.font
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.heightAnchor.constraint(equalToConstant: 1).isActive = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var timeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Menlo", size: 20)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var completedLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .bold)
        label.textAlignment = .right
        label.text = "COMPLETED"
        label.textColor = .green
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
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
    override func prepareForReuse() {
        super.prepareForReuse()
        //emomModel.completed.valueChanged = nil
        completedLabel.isHidden = true
    }
}

// MARK: - Setup UI
private extension MainWorkoutEMOMCollectionCell {
    func setupUI() {
        backgroundColor = .offWhiteColour
        layer.cornerRadius = 10
        layer.masksToBounds = true
        addSubview(emomLabel)
        addSubview(separatorView)
        addSubview(timeLabel)
//        addSubview(completedLabel)
        constrainUI()
    }
    
    func constrainUI() {
        NSLayoutConstraint.activate([
            emomLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            emomLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            
            separatorView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 5),
            separatorView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -5),
            separatorView.topAnchor.constraint(equalTo: emomLabel.bottomAnchor, constant: 10),
            
            timeLabel.topAnchor.constraint(equalTo: separatorView.bottomAnchor, constant: 20),
            timeLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            timeLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            
//            completedLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10),
//            completedLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -5),
        ])
    }
}

// MARK: - Public Configuration
extension MainWorkoutEMOMCollectionCell {
    
    func configure(with model: EMOMModel) {
        timeLabel.text = model.timeLimit.convertToWorkoutTime()
    }
}
