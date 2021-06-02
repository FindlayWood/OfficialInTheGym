//
//  NumberCell.swift
//  InTheGym
//
//  Created by Findlay Wood on 18/05/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit

class SetsCell: UICollectionViewCell {
    
    lazy var numberLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .clear
        label.textColor = .white
        label.font = .systemFont(ofSize: 27, weight: .bold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    private func setupView() {
        addSubview(numberLabel)
        layer.cornerRadius = 40
        layer.borderWidth = 2.0
        layer.borderColor = UIColor.black.cgColor
        backgroundColor = Constants.lightColour
        constrain()
    }
    
    private func constrain() {
        NSLayoutConstraint.activate([numberLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
                                     numberLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
        
                                     numberLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
                                     numberLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
                                     numberLabel.topAnchor.constraint(equalTo: topAnchor),
                                     numberLabel.bottomAnchor.constraint(equalTo: bottomAnchor)])
    }
    
    override func prepareForReuse() {
        backgroundColor = Constants.lightColour
    }
}
