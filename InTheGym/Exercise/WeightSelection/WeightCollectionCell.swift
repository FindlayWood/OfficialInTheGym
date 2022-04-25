//
//  WeightCollectionCell.swift
//  InTheGym
//
//  Created by Findlay Wood on 16/06/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit

class WeightCollectionCell: UICollectionViewCell {
    
    // MARK: - Properties
    static let reuseID: String = "WeightCollectionCellreuseID"
    
    // MARK: - Subviews
    var setLabel: UILabel = {
        let label = UILabel()
        label.font = Constants.font
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var repsLabel: UILabel = {
        let label = UILabel()
        label.font = Constants.font
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var weightLabel: UILabel = {
        let label = UILabel()
        label.font = Constants.font
        label.textColor = .white
        label.textAlignment = .center
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
        backgroundColor = Constants.lightColour
    }
}

// MARK: - Setup UI
private extension WeightCollectionCell {
    
    func setupUI() {
        backgroundColor = Constants.lightColour
        layer.cornerRadius = 10
        layer.masksToBounds = true
        layer.borderWidth = 2.0
        layer.borderColor = UIColor.black.cgColor
        addSubview(setLabel)
        addSubview(repsLabel)
        addSubview(weightLabel)
        constrainUI()
    }
    
    func constrainUI() {
        NSLayoutConstraint.activate([setLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
                                     repsLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
                                     weightLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
        
                                     setLabel.topAnchor.constraint(equalTo: topAnchor, constant: 5),
                                     repsLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
                                     weightLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5)])
    }
}
// MARK: - Public Configuration
extension WeightCollectionCell {
    func updateWeightLabel(with newValue: String) {
        weightLabel.text = newValue
    }
    func setUpData(with model: WeightModel) {
        weightLabel.text = model.weight
        repsLabel.text = model.rep.description + " reps"
        setLabel.text = "SET " + model.index.description
    }
}
