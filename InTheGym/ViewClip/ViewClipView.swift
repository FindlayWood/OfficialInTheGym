//
//  ViewClipView.swift
//  InTheGym
//
//  Created by Findlay Wood on 20/07/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import UIKit

class ViewClipView: UIView {
    
    // MARK: - Subviews
    var thumbnailImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.backgroundColor = .lightGray
        view.layer.cornerRadius = 8
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = true
        return view
    }()
    var backButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .white
        button.setImage(UIImage(systemName: "chevron.backward.circle.fill"), for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.tintColor = .darkColour
        button.layer.cornerRadius = 20
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    var loadingIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView()
        view.style = .large
        view.color = .white
        view.hidesWhenStopped = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var progressBar: UIView = {
       let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var exerciseName: UILabel = {
        let label = UILabel()
        label.font = Constants.font
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var moreButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .white
        button.setImage(UIImage(named: "more_icon"), for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.cornerRadius = 30
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    var viewsView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.borderWidth = 2
        view.layer.borderColor = UIColor.black.cgColor
        view.layer.cornerRadius = 30
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var viewLabel: UILabel = {
        let label = UILabel()
        label.text = "100"
        label.font = UIFont(name: "Menlo-Bold", size: 12)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var likeButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .white
        button.setTitle("L", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.cornerRadius = 30
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    var stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 10
        stack.distribution = .equalSpacing
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    required init?(coder: NSCoder) {
        fatalError()
    }
    
}

// MARK: - Setup UI
private extension ViewClipView {
    
    func setupUI() {
//        addSubview(thumbnailImageView)
        addSubview(backButton)
        addSubview(loadingIndicator)
        addSubview(progressBar)
        addSubview(exerciseName)
        
        viewsView.addSubview(viewLabel)
        
//        stackView.addArrangedSubview(moreButton)
//        stackView.addArrangedSubview(viewsView)
//        stackView.addArrangedSubview(likeButton)
        
        viewsView.isHidden = true
        likeButton.isHidden = true
        
        //addSubview(stackView)
        
        addSubview(moreButton)
        
        progressBar.frame = CGRect(x: 0, y: 0, width: 0, height: 5)
        constrainView()
    }
    func constrainView() {
        NSLayoutConstraint.activate([
            
//            thumbnailImageView.topAnchor.constraint(equalTo: topAnchor),
//            thumbnailImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
//            thumbnailImageView.trailingAnchor.constraint(equalTo: trailingAnchor),
//            thumbnailImageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            backButton.widthAnchor.constraint(equalToConstant: 40),
            backButton.heightAnchor.constraint(equalToConstant: 40),
            backButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            backButton.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            
            exerciseName.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            exerciseName.centerXAnchor.constraint(equalTo: centerXAnchor),
            
            loadingIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            viewLabel.centerXAnchor.constraint(equalTo: viewsView.centerXAnchor),
            viewLabel.centerYAnchor.constraint(equalTo: viewsView.centerYAnchor),
            
            moreButton.widthAnchor.constraint(equalToConstant: 60),
            moreButton.heightAnchor.constraint(equalToConstant: 60),
            
            moreButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            moreButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            
            viewsView.widthAnchor.constraint(equalToConstant: 60),
            viewsView.heightAnchor.constraint(equalToConstant: 60),
            
            likeButton.widthAnchor.constraint(equalToConstant: 60),
            likeButton.heightAnchor.constraint(equalToConstant: 60),
            
            //                                     stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            //                                     stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            //                                     stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20)
            
        ])
    }
}

// MARK: - Public Configuration
extension ViewClipView {
    public func setLoading(to loading: Bool) {
        if loading {
            loadingIndicator.startAnimating()
            UIView.animate(withDuration: 0.3) { [weak self] in
                self?.thumbnailImageView.isHidden = false
            }
        } else {
            loadingIndicator.stopAnimating()
            UIView.animate(withDuration: 0.3) { [weak self] in
                self?.thumbnailImageView.isHidden = true
            }
        }
    }
    
    public func updateProgressBar(currentTime: Double, videolength: Double) {
        let progress = CGFloat((currentTime) / videolength)
        if progress == 0 {
            self.progressBar.frame = CGRect(x: 0, y: 0, width: 0, height: 5)
        } else {
            UIView.animate(withDuration: 0.25) {
                self.progressBar.frame = CGRect(x: 0, y: 0, width: Constants.screenSize.width * progress, height: 5)
            }
        }
    }
}
