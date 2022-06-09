//
//  ExerciseDescriptionView.swift
//  InTheGym
//
//  Created by Findlay Wood on 16/02/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
import UIKit

class ExerciseDescriptionView: UIView {
    // MARK: - Properties
    
    // MARK: - Subviews
    var segmentControl: CustomUnderlineSegmentControl = {
        let view = CustomUnderlineSegmentControl(frame: CGRect(x: 0, y: 0, width: Constants.screenSize.width, height: 32), buttonTitles: ["Clips", "Comments", "Tags"])
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: UIScreen.main.bounds)
        setupUI()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
}
// MARK: - Configure
private extension ExerciseDescriptionView {
    func setupUI() {
        backgroundColor = .white
        addSubview(segmentControl)
        addSubview(containerView)
        configureUI()
    }
    
    func configureUI() {
        NSLayoutConstraint.activate([
            segmentControl.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            segmentControl.leadingAnchor.constraint(equalTo: leadingAnchor),
            segmentControl.trailingAnchor.constraint(equalTo: trailingAnchor),
            segmentControl.heightAnchor.constraint(equalToConstant: 32),
            
            containerView.topAnchor.constraint(equalTo: segmentControl.bottomAnchor, constant: 16),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}

// MARK: - View Controller Extension
extension ExerciseDescriptionViewController {
    func setupUI() {
        view.backgroundColor = .white
        view.addSubview(display.segmentControl)
        view.addSubview(display.containerView)
        configureUI()
    }
    func configureUI() {
        NSLayoutConstraint.activate([
            display.segmentControl.topAnchor.constraint(equalTo: view.topAnchor, constant: view.safeAreaInsets.top),
            display.segmentControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            display.segmentControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            display.segmentControl.heightAnchor.constraint(equalToConstant: 50),
            
            display.containerView.topAnchor.constraint(equalTo: display.segmentControl.bottomAnchor, constant: 16),
            display.containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            display.containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            display.containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: view.safeAreaInsets.bottom)
        ])
    }
}
