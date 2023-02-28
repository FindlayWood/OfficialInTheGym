//
//  PostWorkoutSubview.swift
//  InTheGym
//
//  Created by Findlay Wood on 22/05/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit

class PostWorkoutSubview: UIView {
    // MARK: - Properties
    
    // MARK: - Subviews
    var workoutView: UIWorkoutView = {
        let view = UIWorkoutView()
        view.backgroundColor = .thirdColour
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
private extension PostWorkoutSubview {
    func setupUI() {
        addSubview(workoutView)
        configureUI()
    }
    
    func configureUI() {
        NSLayoutConstraint.activate([
            workoutView.topAnchor.constraint(equalTo: topAnchor),
            workoutView.leadingAnchor.constraint(equalTo: leadingAnchor),
            workoutView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            workoutView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}
