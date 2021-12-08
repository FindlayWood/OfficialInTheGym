//
//  UIViewController+Extension.swift
//  InTheGym
//
//  Created by Findlay Wood on 19/11/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    
    func displayTopMessage(with message: String) {
        let viewHeight = view.bounds.height * 0.07
        let screenWidth = view.bounds.width
        let viewWidth = view.bounds.width * 0.8
        let margins = navigationController?.view.safeAreaInsets
        
        let startingPoint = CGRect(x: (screenWidth * 0.1), y: -30 - viewHeight, width: viewWidth, height: viewHeight)
        let showingPoint = CGRect(x: (screenWidth * 0.1), y: margins!.top, width: viewWidth, height: viewHeight)
        
        let label: UILabel = {
            let label = UILabel()
            label.font = .systemFont(ofSize: 20, weight: .bold)
            label.textColor = .white
            label.adjustsFontSizeToFitWidth = true
            label.minimumScaleFactor = 0.25
            label.text = message
            label.textAlignment = .center
            label.translatesAutoresizingMaskIntoConstraints = false
            return label
        }()
        let topView: UIView = {
            let view = UIView(frame: startingPoint)
            view.backgroundColor = .darkColour
            view.layer.borderWidth = 4.0
            view.layer.borderColor = UIColor.white.cgColor
            view.layer.cornerRadius = 20
            return view
        }()
        
        topView.addSubview(label)
        label.centerXAnchor.constraint(equalTo: topView.centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: topView.centerYAnchor).isActive = true
        label.leadingAnchor.constraint(equalTo: topView.leadingAnchor, constant: 2).isActive = true
        label.trailingAnchor.constraint(equalTo: topView.trailingAnchor, constant: -2).isActive = true
        
        navigationController?.view.addSubview(topView)
        
        UIView.animate(withDuration: 0.6) {
            topView.frame = showingPoint
        } completion: { (_) in
            UIView.animate(withDuration: 0.6, delay: 2.8, options: .curveEaseOut) {
                topView.frame = startingPoint
                } completion: { (_) in
                    topView.removeFromSuperview()
            }
        }

    }
    
}