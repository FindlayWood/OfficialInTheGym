//
//  RecordedClipView.swift
//  InTheGym
//
//  Created by Findlay Wood on 01/07/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import UIKit

class RecordedClipView: UIView {
    
    var backButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .white
        if #available(iOS 13.0, *) {
            button.setImage(UIImage(systemName: "chevron.backward.circle.fill"), for: .normal)
        } else {
            button.setTitle("X", for: .normal)
        }
        button.setTitleColor(.black, for: .normal)
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.cornerRadius = 20
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private var privateImage = UIImage(named:"locked_icon")
    private var publicImage = UIImage(named: "public_icon")
    var isPrivate: Bool = false
    
    lazy var privacyButton: UIButton = {
        let button = UIButton()
        button.setImage(publicImage, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    var saveButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = Constants.lightColour
        button.setTitle("UPLOAD", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = Constants.font
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.cornerRadius = 20
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    var savingIndicator: UIActivityIndicatorView = {
       let view = UIActivityIndicatorView()
        view.color = .white
        view.style = .whiteLarge
        view.hidesWhenStopped = true
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var uploadProgressBar: UIView = {
        let view = UIView()
        view.backgroundColor = .blue
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
        
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpView()
    }
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    func setUpView() {
        addSubview(backButton)
        addSubview(privacyButton)
        addSubview(saveButton)
        addSubview(savingIndicator)
        addSubview(uploadProgressBar)
        uploadProgressBar.frame = CGRect(x: 0, y: 0, width: 0, height: 10)
        constrainView()
    }
    func constrainView() {
        NSLayoutConstraint.activate([backButton.widthAnchor.constraint(equalToConstant: 40),
                                     backButton.heightAnchor.constraint(equalToConstant: 40),
                                     backButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
                                     backButton.topAnchor.constraint(equalTo: topAnchor),
                                     
                                     privacyButton.topAnchor.constraint(equalTo: topAnchor),
                                     privacyButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
                                     
                                     saveButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20),
                                     saveButton.centerXAnchor.constraint(equalTo: centerXAnchor),
                                     saveButton.heightAnchor.constraint(equalToConstant: 40),
                                     saveButton.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.5),
                                     
                                     savingIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
                                     savingIndicator.centerYAnchor.constraint(equalTo: centerYAnchor),
                                     
                                     ])
    }
    
    func attemptingToSaveClip() {
        savingIndicator.isHidden = false
        uploadProgressBar.isHidden = false
        saveButton.isUserInteractionEnabled = false
        backButton.isUserInteractionEnabled = false
        savingIndicator.startAnimating()
    }
    
    func setToRecord() {
        savingIndicator.isHidden = true
        uploadProgressBar.isHidden = true
        saveButton.isUserInteractionEnabled = true
        backButton.isUserInteractionEnabled = true
        savingIndicator.stopAnimating()
    }
    
    func updateProgressBar(to percent: Double) {
        UIView.animate(withDuration: 0.25) {
            self.uploadProgressBar.frame = CGRect(x: 0, y: 0, width: Constants.screenSize.width * CGFloat(percent), height: 10)
        }
    }
    
    func togglePrivacy() {
        if isPrivate {
            privacyButton.setImage(publicImage, for: .normal)
            isPrivate = false
        } else {
            privacyButton.setImage(privateImage, for: .normal)
            isPrivate = true
        }
    }
    
}
