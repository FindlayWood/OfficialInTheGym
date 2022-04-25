//
//  CustomTopView.swift
//  InTheGym
//
//  Created by Findlay Wood on 12/11/2020.
//  Copyright © 2020 FindlayWood. All rights reserved.
//

import Foundation
import UIKit

class AlertTopView: UIView {
    
    lazy var message: UILabel = {
       let label = UILabel()
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        return label
    }()

    let alertWidth = UIScreen.main.bounds.width - 10
    let startingPoint: CGRect = CGRect(x: 5, y: -60, width: UIScreen.main.bounds.width - 10, height: 60)
    let showingPoint: CGRect!
    
    init(frame: CGRect, message: String) {
        self.showingPoint = frame
        super.init(frame: startingPoint)
        self.message.text = message
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func setupView() {
        backgroundColor = Constants.darkColour
        layer.cornerRadius = 10
        layer.shadowRadius = 6
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 1.0
        addSubview(message)
        addConstraints()
    }
    
    private func addConstraints() {
        NSLayoutConstraint.activate([message.centerXAnchor.constraint(equalTo: centerXAnchor),
                                     message.centerYAnchor.constraint(equalTo: centerYAnchor)])
        animatePosition()
    }
    
    private func animatePosition() {
        UIView.animate(withDuration: 0.3) {
            self.frame = self.showingPoint
        } completion: { _ in
            UIView.animate(withDuration: 0.3, delay: 1.0, options: .curveEaseIn) {
                self.frame = self.startingPoint
            } completion: { _ in
                self.removeFromSuperview()
            }
        }
    }
}

extension UIViewController {
    func showTopAlert(with message: String) {
        let margins = self.view.safeAreaInsets
        let showingFrame = CGRect(x: 5, y: margins.top, width: UIScreen.main.bounds.width, height: 60)
        let alert = AlertTopView(frame: showingFrame, message: message)
        self.view.addSubview(alert)
    }
}
