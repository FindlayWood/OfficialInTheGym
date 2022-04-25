//
//  UIProgressView.swift
//  InTheGym
//
//  Created by Findlay Wood on 20/04/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit

class UIProgressView: UIView {
    
    // MARK: - Properties
    
    // MARK: - Subviews
    var underlayView: UIView = {
        let view = UIView()
        view.backgroundColor = .darkGray
        view.layer.cornerRadius = 8
        view.heightAnchor.constraint(equalToConstant: 16).isActive = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var overlayView: UIView = {
        let view = UIView()
        view.backgroundColor = .thirdColour
        view.layer.cornerRadius = 8
        view.heightAnchor.constraint(equalToConstant: 16).isActive = true
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
private extension UIProgressView {
    func setupUI() {
        addSubview(underlayView)
        addSubview(overlayView)
        configureUI()
    }
    
    func configureUI() {
        addFullConstraint(to: underlayView)
        NSLayoutConstraint.activate([
            underlayView.topAnchor.constraint(equalTo: topAnchor),
            underlayView.leadingAnchor.constraint(equalTo: leadingAnchor),
            underlayView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}

// MARK: - Public Config
extension UIProgressView {
    public func configure(percent: Double) {
        NSLayoutConstraint.activate([
            overlayView.widthAnchor.constraint(equalTo: underlayView.widthAnchor, multiplier: percent)
        ])
    }
}
