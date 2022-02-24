//
//  NumberCircleCollectionCell.swift
//  InTheGym
//
//  Created by Findlay Wood on 21/02/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//
import Foundation
import UIKit

final class NumberCircleCollectionCell: UICollectionViewCell {
    
    // MARK: - Properties
    static let reuseID = "NumberCircleCollectionCellreuseID"
    
    // MARK: - Subviews
    var numberLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .clear
        label.textColor = .white
        label.font = .systemFont(ofSize: 27, weight: .bold)
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
    
}
// MARK: - Configure
private extension NumberCircleCollectionCell {
    func setupUI() {
        backgroundColor = .darkColour
        addViewShadow(with: .darkColour)
        layer.cornerRadius = 40
        addSubview(numberLabel)
        configureUI()
    }
    
    func configureUI() {
        NSLayoutConstraint.activate([
            numberLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            numberLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            
            numberLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            numberLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            numberLabel.topAnchor.constraint(equalTo: topAnchor),
            numberLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}

// MARK: - Public Configuration
extension NumberCircleCollectionCell {
    public func configure(with number: Int) {
        numberLabel.text = number.description
    }
}
