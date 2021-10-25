//
//  ReplayJumpMeasureView.swift
//  InTheGym
//
//  Created by Findlay Wood on 16/10/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import UIKit

class ReplayJumpMeasureView: UIView {
    
    // MARK: - Subviews
    var imageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var backButton: UIButton = {
        let button = UIButton()
        if #available(iOS 13.0, *) {
            let largeConfig = UIImage.SymbolConfiguration(pointSize: 50, weight: .bold, scale: .large)
            let image = UIImage(systemName: "chevron.backward.circle.fill", withConfiguration: largeConfig)
            button.setImage(image, for: .normal)
        } else {
            button.setTitle("X", for: .normal)
        }
        button.tintColor = .lightColour
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    var calculateButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .lightColour
        button.setTitleColor(.white, for: .normal)
        button.setTitle(" Calculate ", for: .normal)
        button.isHidden = true
        button.layer.cornerRadius = 8
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.black.cgColor
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    var slider: UISlider = {
        let slider = UISlider()
        slider.minimumTrackTintColor = .lightColour.withAlphaComponent(0.6)
        slider.maximumTrackTintColor = .white.withAlphaComponent(0.6)
        slider.thumbTintColor = .lightColour
        slider.translatesAutoresizingMaskIntoConstraints = false
        return slider
    }()
        
    var forwardFrameButton: UIButton = {
        let button = UIButton()
        if #available(iOS 13.0, *) {
            let largeConfig = UIImage.SymbolConfiguration(pointSize: 50, weight: .bold, scale: .large)
            let image = UIImage(systemName: "chevron.forward.square.fill", withConfiguration: largeConfig)
            button.setImage(image, for: .normal)
        } else {
            button.setTitle(">", for: .normal)
        }
        button.tintColor = .lightColour.withAlphaComponent(0.6)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    var backwardFrameButton: UIButton = {
        let button = UIButton()
        if #available(iOS 13.0, *) {
            let largeConfig = UIImage.SymbolConfiguration(pointSize: 50, weight: .bold, scale: .large)
            let image = UIImage(systemName: "chevron.backward.square.fill", withConfiguration: largeConfig)
            button.setImage(image, for: .normal)
        } else {
            button.setTitle(">", for: .normal)
        }
        button.tintColor = .lightColour.withAlphaComponent(0.6)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    var selectedTakeOffFrameButton: UIButton = {
        let button = UIButton()
        button.setTitle("Select Take Off", for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 25)
        button.backgroundColor = .lightColour.withAlphaComponent(0.6)
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.black.cgColor
        button.setTitleColor(.white, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    var selectLandingFrameButton: UIButton = {
        let button = UIButton()
        button.setTitle("Select Landing", for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 25)
        button.backgroundColor = .lightColour.withAlphaComponent(0.6)
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.black.cgColor
        button.setTitleColor(.white, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpView()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUpView()
    }
}

// MARK: - Configure
private extension ReplayJumpMeasureView {
    func setUpView() {
        addSubview(imageView)
        addSubview(backButton)
        addSubview(calculateButton)
        addSubview(slider)
        addSubview(forwardFrameButton)
        addSubview(backwardFrameButton)
        addSubview(selectedTakeOffFrameButton)
        addSubview(selectLandingFrameButton)
        constrainView()
    }
    func constrainView() {
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
                                    backButton.widthAnchor.constraint(equalToConstant: 40),
                                     backButton.heightAnchor.constraint(equalToConstant: 40),
                                     backButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
                                     backButton.topAnchor.constraint(equalTo: topAnchor),
            
            calculateButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            calculateButton.topAnchor.constraint(equalTo: topAnchor, constant: 20),
                                     
                                     selectedTakeOffFrameButton.leadingAnchor.constraint(equalTo: leadingAnchor),
                                     selectedTakeOffFrameButton.bottomAnchor.constraint(equalTo: bottomAnchor),
                                     selectedTakeOffFrameButton.trailingAnchor.constraint(equalTo: centerXAnchor),
                                     selectedTakeOffFrameButton.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.1),
                                     
                                     selectLandingFrameButton.leadingAnchor.constraint(equalTo: centerXAnchor),
                                     selectLandingFrameButton.bottomAnchor.constraint(equalTo: bottomAnchor),
                                     selectLandingFrameButton.trailingAnchor.constraint(equalTo: trailingAnchor),
                                     selectLandingFrameButton.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.1),
            
            slider.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            slider.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            slider.bottomAnchor.constraint(equalTo: selectLandingFrameButton.topAnchor, constant: -10),
                                     
                                     forwardFrameButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
                                     forwardFrameButton.bottomAnchor.constraint(equalTo: slider.topAnchor, constant: -10),
                                     forwardFrameButton.heightAnchor.constraint(equalTo: widthAnchor, multiplier: 0.2),
                                     forwardFrameButton.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.2),
                                     
                                     backwardFrameButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
                                     backwardFrameButton.bottomAnchor.constraint(equalTo: slider.topAnchor, constant: -10),
                                     backwardFrameButton.heightAnchor.constraint(equalTo: widthAnchor, multiplier: 0.2),
                                     backwardFrameButton.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.2),
                                    
                                     ])
    }
}
