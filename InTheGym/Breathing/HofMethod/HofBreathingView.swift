//
//  HofBreathingView.swift
//  InTheGym
//
//  Created by Findlay Wood on 11/04/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit

class HofBreathingView: UIView {
    
    // MARK: - Properties
    
    // MARK: - Subviews
    var centerCircle: UIView = {
        let view = UIView()
        view.addViewShadow(with: .darkColour)
        view.backgroundColor = .lightColour
        view.layer.cornerRadius = Constants.screenSize.width / 4
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var centerLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 30, weight: .bold)
        label.textColor = .white
        label.text = "Start"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var holdTimerLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 60, weight: .bold)
        label.textColor = .darkColour
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.2
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
private extension HofBreathingView {
    func setupUI() {
        backgroundColor = .white
        addSubview(centerCircle)
        addSubview(centerLabel)
        addSubview(holdTimerLabel)
        configureUI()
    }
    
    func configureUI() {
        NSLayoutConstraint.activate([
            centerCircle.centerXAnchor.constraint(equalTo: centerXAnchor),
            centerCircle.centerYAnchor.constraint(equalTo: centerYAnchor),
            centerCircle.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.5),
            centerCircle.heightAnchor.constraint(equalTo: centerCircle.widthAnchor),
            
            centerLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            centerLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            holdTimerLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            holdTimerLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            holdTimerLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16)
        ])
    }
}

// MARK: - Public Configuration
extension HofBreathingView {
    public func setDisplay(to stage: BreathingStage) {
        switch stage {
        case .ready:
            centerCircle.isUserInteractionEnabled = false
            centerLabel.text = "Ready"
        case .breatheIn:
            centerLabel.text = "In"
            UIView.animate(withDuration: 1.5, delay: 0.0, options: .curveEaseOut) {
                self.centerCircle.transform = CGAffineTransform.identity.scaledBy(x: 1.1, y: 1.1)
                self.centerLabel.transform = CGAffineTransform.identity.scaledBy(x: 1.1, y: 1.1)
            }
        case .breatheOut:
            centerLabel.text = "Out"
            UIView.animate(withDuration: 1.5) {
                self.centerCircle.transform = CGAffineTransform.identity.scaledBy(x: 0.6, y: 0.6)
                self.centerLabel.transform = CGAffineTransform.identity.scaledBy(x: 0.6, y: 0.6)
            }
        case .hold:
            centerLabel.text = "Hold"
        }
    }
    
    public func updateHoldTimer(with seconds: Int) {
        holdTimerLabel.text = seconds.convertToTime()
    }
    
    public func roundComplete(_ round: Int) {
        holdTimerLabel.text = "Round \(round) Complete"
    }
    
    public func showFully(_ stage: BreathingStage) {
        switch stage {
        case .breatheIn:
            holdTimerLabel.text = "Fully In"
        case .breatheOut:
            holdTimerLabel.text = "Fully Out"
        default:
            break
        }
    }
    
    public func completed() {
        holdTimerLabel.text = "Breathing Completed"
    }
}
