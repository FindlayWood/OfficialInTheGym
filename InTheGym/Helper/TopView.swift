//
//  TopView.swift
//  InTheGym
//
//  Created by Findlay Wood on 24/02/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import UIKit

class DisplayTopView{
    
    // this function displays a custom top view letting user know exercise has been added
    static func displayTopView(with message:String, on parent:UIViewController){
        
        let viewHeight = parent.view.bounds.height * 0.1
        let screenWidth = parent.view.bounds.width
        let viewWidth = parent.view.bounds.width * 0.8
        let margins = parent.navigationController?.view.safeAreaInsets
        
        let startingPoint = CGRect(x: (screenWidth * 0.1), y: -30 - viewHeight, width: viewWidth, height: viewHeight)
        let showingPoint = CGRect(x: (screenWidth * 0.1), y: margins!.top, width: viewWidth, height: viewHeight)
        
        
//        let topView = CustomTopView(frame: startingPoint)
//        topView.image = UIImage(named: "Workout Completed")
//        topView.message = message
//        topView.label.textColor = .white
//        topView.backgroundColor = Constants.darkColour
//        topView.layer.cornerRadius = 0
//        topView.layer.borderColor = Constants.darkColour.cgColor
//        //parent.navigationController?.view.addSubview(topView)
        let topView = UIView(frame: startingPoint)
        topView.backgroundColor = Constants.darkColour
        topView.layer.cornerRadius = 20
        topView.layer.borderWidth = 4
        topView.layer.borderColor = UIColor.white.cgColor
        let label = UILabel()
        label.text = message
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 25)
        label.translatesAutoresizingMaskIntoConstraints = false
        topView.addSubview(label)
        label.centerXAnchor.constraint(equalTo: topView.centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: topView.centerYAnchor).isActive = true
        parent.navigationController?.view.addSubview(topView)
        
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
