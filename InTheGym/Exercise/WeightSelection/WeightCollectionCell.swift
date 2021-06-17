//
//  WeightCollectionCell.swift
//  InTheGym
//
//  Created by Findlay Wood on 16/06/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import UIKit

class WeightCollectionCell: UICollectionViewCell {
    
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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    private func setUpCell() {
        backgroundColor = Constants.lightColour
        layer.cornerRadius = 10
        layer.masksToBounds = true
        layer.borderWidth = 2.0
        layer.borderColor = UIColor.black.cgColor
        addSubview(setLabel)
        addSubview(repsLabel)
        addSubview(weightLabel)
        constrainCell()
    }
    
    private func constrainCell() {
        NSLayoutConstraint.activate([setLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
                                     repsLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
                                     weightLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
        
                                     setLabel.topAnchor.constraint(equalTo: topAnchor, constant: 5),
                                     repsLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
                                     weightLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5)])
    }
    func updateWeightLabel(with newValue: String) {
        weightLabel.text = newValue
    }
    func setUpData(with model: WeightModel) {
        weightLabel.text = model.weight
        repsLabel.text = model.rep.description + " reps"
        setLabel.text = "SET " + model.index.description
    }
    override func prepareForReuse() {
        backgroundColor = Constants.lightColour
    }
}
