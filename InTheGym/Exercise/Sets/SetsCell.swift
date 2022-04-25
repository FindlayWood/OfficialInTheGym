//
//  NumberCell.swift
//  InTheGym
//
//  Created by Findlay Wood on 18/05/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit

class SetsCell: UICollectionViewCell {
    
    // MARK: - Properties
    static var cellID = "SetsCellID"
    
    static let setNumbers = [Int](0...20)
    
    static let repNumbers = [Int](0...100)
    
    // MARK: - Subviews
    lazy var numberLabel: UILabel = {
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
    override func prepareForReuse() {
        backgroundColor = .lightColour
    }
}

// MARK: - Setup UI
private extension SetsCell {
    func setupUI() {
        addSubview(numberLabel)
        layer.cornerRadius = 40
        layer.borderWidth = 2.0
        layer.borderColor = UIColor.black.cgColor
        backgroundColor = .lightColour
        constrainUI()
    }
    
    func constrainUI() {
        NSLayoutConstraint.activate([numberLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
                                     numberLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
        
                                     numberLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
                                     numberLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
                                     numberLabel.topAnchor.constraint(equalTo: topAnchor),
                                     numberLabel.bottomAnchor.constraint(equalTo: bottomAnchor)])
    }
}

// MARK: - Public Configuration
extension SetsCell {
    public func configure(with number: Int) {
        if number == 0 {
            numberLabel.text = "M"
        } else {
            numberLabel.text = number.description
        }
    }
}
