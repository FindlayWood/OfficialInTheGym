//
//  AssigningSelectionView.swift
//  InTheGym
//
//  Created by Findlay Wood on 18/04/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
import UIKit

class AssigningSelectionView: UIView {
    
    // MARK: - Properties
    
    // MARK: - Subviews
    var segmentControl: CustomisedSegmentControl = {
        let view = CustomisedSegmentControl(frame: .zero, buttonTitles: ["Players", "Groups"])
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
        super.init(frame: frame)
        setupUI()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
}
// MARK: - Configure
private extension AssigningSelectionView {
    func setupUI() {
        backgroundColor = .white
        addSubview(segmentControl)
        addSubview(containerView)
        configureUI()
    }
    
    func configureUI() {
        NSLayoutConstraint.activate([
            segmentControl.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            segmentControl.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            segmentControl.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            segmentControl.heightAnchor.constraint(equalToConstant: 48),
            
            containerView.topAnchor.constraint(equalTo: segmentControl.bottomAnchor, constant: 16),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}
