//
//  UITopMessageView.swift
//  InTheGym
//
//  Created by Findlay Wood on 24/01/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
import UIKit

// MARK: - Top Message View
///Displays a message at the top of the screen for a brief period of time
class UITopMessageView: UIView {
    // MARK: - Properties
    
    // MARK: - Subviews
    let label: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = .white
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.25
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
private extension UITopMessageView {
    func setupUI() {
        backgroundColor = .darkColour
        layer.borderWidth = 4.0
        layer.borderColor = UIColor.white.cgColor
        layer.cornerRadius = 20
        addSubview(label)
        configureUI()
    }
    
    func configureUI() {
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: centerXAnchor),
            label.centerYAnchor.constraint(equalTo: centerYAnchor),
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 2),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -2)
        ])
    }
}
// MARK: - Public Configuration
extension UITopMessageView {
    func configure(with text: String) {
        label.text = text
    }
}

