//
//  MethodSelectionView.swift
//  InTheGym
//
//  Created by Findlay Wood on 13/04/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit

class MethodSelectionView: UIView {
    // MARK: - Properties
    
    // MARK: - Subviews
    var hofButton: UIButton = {
        let button = UIButton()
        button.setTitle("Deep Breathing", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .darkColour
        button.addViewShadow(with: .darkColour)
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    var boxButton: UIButton = {
        let button = UIButton()
        button.setTitle("Box Breathing", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .darkColour
        button.addViewShadow(with: .darkColour)
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
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
private extension MethodSelectionView {
    func setupUI() {
        backgroundColor = .white
        addSubview(hofButton)
        addSubview(boxButton)
        configureUI()
    }
    
    func configureUI() {
        NSLayoutConstraint.activate([
            hofButton.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            hofButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            hofButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            hofButton.heightAnchor.constraint(equalToConstant: 48),
            
            boxButton.topAnchor.constraint(equalTo: hofButton.bottomAnchor, constant: 16),
            boxButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            boxButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            boxButton.heightAnchor.constraint(equalToConstant: 48),
        ])
    }
}
