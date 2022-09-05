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
    var backButton: UIButton = {
        let button = UIButton()
        let image = UIImage(systemName: "xmark", withConfiguration: UIImage.SymbolConfiguration(pointSize: 30))
        button.setImage(image, for: .normal)
        button.tintColor = .lightColour
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    var calculateButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "arrow.forward.circle.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 35)), for: .normal)
        button.tintColor = .lightColour
        button.isHidden = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    var slider: UISlider = {
        let slider = UISlider()
        slider.minimumTrackTintColor = .lightColour.withAlphaComponent(0.6)
        slider.maximumTrackTintColor = .white.withAlphaComponent(0.6)
        slider.thumbTintColor = .lightColour
        slider.maximumValue = 1
        slider.translatesAutoresizingMaskIntoConstraints = false
        return slider
    }()
    var forwardFrameButton: UIButton = {
        let button = UIButton()
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 50, weight: .bold, scale: .large)
        let image = UIImage(systemName: "chevron.forward.square.fill", withConfiguration: largeConfig)
        button.setImage(image, for: .normal)
        button.tintColor = .lightColour.withAlphaComponent(0.6)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    var backwardFrameButton: UIButton = {
        let button = UIButton()
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 50, weight: .bold, scale: .large)
        let image = UIImage(systemName: "chevron.backward.square.fill", withConfiguration: largeConfig)
        button.setImage(image, for: .normal)
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
    var takeOffImage: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.backgroundColor = .clear
        view.tintColor = .white
        view.image = UIImage(systemName: "arrow.up")
        return view
    }()
    var landingImage: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.backgroundColor = .clear
        view.image = UIImage(systemName: "arrow.down")
        view.tintColor = .white
        return view
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
            backButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            backButton.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 8),
            
            calculateButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            calculateButton.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 8),
            
            selectedTakeOffFrameButton.leadingAnchor.constraint(equalTo: leadingAnchor),
            selectedTakeOffFrameButton.bottomAnchor.constraint(equalTo: bottomAnchor),
            selectedTakeOffFrameButton.trailingAnchor.constraint(equalTo: centerXAnchor),
            selectedTakeOffFrameButton.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.1),
            
            selectLandingFrameButton.leadingAnchor.constraint(equalTo: centerXAnchor),
            selectLandingFrameButton.bottomAnchor.constraint(equalTo: bottomAnchor),
            selectLandingFrameButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            selectLandingFrameButton.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.1),
            
            slider.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            slider.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            slider.bottomAnchor.constraint(equalTo: selectLandingFrameButton.topAnchor, constant: -8),
            
            forwardFrameButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            forwardFrameButton.bottomAnchor.constraint(equalTo: slider.topAnchor, constant: -16),
            forwardFrameButton.heightAnchor.constraint(equalTo: widthAnchor, multiplier: 0.2),
            forwardFrameButton.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.2),
            
            backwardFrameButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            backwardFrameButton.bottomAnchor.constraint(equalTo: slider.topAnchor, constant: -16),
            backwardFrameButton.heightAnchor.constraint(equalTo: widthAnchor, multiplier: 0.2),
            backwardFrameButton.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.2),
        ])
    }
}
// MARK: - Public
extension ReplayJumpMeasureView {
    public func selectedTakeOff() {
        selectedTakeOffFrameButton.backgroundColor = .lightColour
    }
    public func selectedLanding() {
        selectLandingFrameButton.backgroundColor = .lightColour
    }
    public func addTakeOffImage() {
        takeOffImage.removeFromSuperview()
        addSubview(takeOffImage)
        let thumbRect = slider.thumbRect(forBounds: slider.bounds, trackRect: slider.trackRect(forBounds: slider.bounds), value: slider.value)
        let sliderFrame = convert(thumbRect, from: slider)
        takeOffImage.frame = sliderFrame.insetBy(dx: 5, dy: 5)
    }
    public func addLandingImage() {
        landingImage.removeFromSuperview()
        addSubview(landingImage)
        let thumbRect = slider.thumbRect(forBounds: slider.bounds, trackRect: slider.trackRect(forBounds: slider.bounds), value: slider.value)
        let sliderFrame = convert(thumbRect, from: slider)
        landingImage.frame = sliderFrame.insetBy(dx: 5, dy: 5)
    }
}
