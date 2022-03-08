//
//  SavedWorkoutBottomChildView.swift
//  InTheGym
//
//  Created by Findlay Wood on 07/03/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
import UIKit

class SavedWorkoutBottomChildView: UIView {
    // MARK: - Properties
    
    // MARK: - Subviews
    var scrollIndicatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .darkGray
        view.heightAnchor.constraint(equalToConstant: 6).isActive = true
        view.layer.cornerRadius = 3
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var optionsLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Menlo-Bold", size: 25)
        label.textColor = .darkColour
        label.text = "OPTIONS"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var newView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
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
private extension SavedWorkoutBottomChildView {
    func setupUI() {
        backgroundColor = .white
        layer.cornerRadius = 10
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        addViewTopShadow(with: .black)
        addSubview(scrollIndicatorView)
        addSubview(optionsLabel)
        addSubview(newView)
        configureUI()
    }
    
    func configureUI() {
        NSLayoutConstraint.activate([
            scrollIndicatorView.topAnchor.constraint(equalTo: topAnchor, constant: 4),
            scrollIndicatorView.centerXAnchor.constraint(equalTo: centerXAnchor),
            scrollIndicatorView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.25),
            
            optionsLabel.topAnchor.constraint(equalTo: scrollIndicatorView.bottomAnchor, constant: 8),
            optionsLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            optionsLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            
            newView.topAnchor.constraint(equalTo: topAnchor, constant: Constants.screenSize.height * 0.075),
            newView.leadingAnchor.constraint(equalTo: leadingAnchor),
            newView.trailingAnchor.constraint(equalTo: trailingAnchor),
            newView.bottomAnchor.constraint(equalTo: bottomAnchor)
            
        ])
    }
}
