//
//  RepsCell.swift
//  InTheGym
//
//  Created by Findlay Wood on 18/05/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit

class RepsCell: UICollectionViewCell {
    
    lazy var setLabel: UILabel = {
       let label = UILabel()
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont(name: "Menlo-Bold", size: 28)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var repLabel: UILabel = {
       let label = UILabel()
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont(name: "Menlo-Bold", size: 28)
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
        addSubview(setLabel)
        addSubview(repLabel)
        backgroundColor = Constants.lightColour
        layer.borderWidth = 2
        layer.borderColor = UIColor.black.cgColor
        layer.cornerRadius = 10
        constrain()
    }
    
    private func constrain() {
        NSLayoutConstraint.activate([setLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
                                     setLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10),
        
                                     repLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
                                     repLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10)])
    }
    
    override func prepareForReuse() {
        backgroundColor = Constants.lightColour
    }
}
