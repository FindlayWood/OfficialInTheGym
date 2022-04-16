//
//  UIPostDataView.swift
//  InTheGym
//
//  Created by Findlay Wood on 16/04/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit

class UIPostDataView: UIView {
    
    
    // MARK: - Properties
    
    // MARK: - Subviews
    var paddingView: UIView = {
        let view = UIView()
        view.heightAnchor.constraint(equalToConstant: 0).isActive = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var workoutView: UIWorkoutView = {
        let view = UIWorkoutView()
        view.isHidden = true
//        view.heightAnchor.constraint(equalToConstant: 110).isActive = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var photoImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.backgroundColor = .lightGray
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var clipImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.backgroundColor = .lightGray
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    lazy var stack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [paddingView, workoutView, photoImageView, clipImageView])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
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
private extension UIPostDataView {
    func setupUI() {
        addSubview(stack)
        configureUI()
    }
    
    func configureUI() {
        addFullConstraint(to: stack)
        NSLayoutConstraint.activate([
            workoutView.widthAnchor.constraint(equalTo: stack.widthAnchor),
//            workoutView.heightAnchor.constraint(equalToConstant: 110)
        ])
    }
}

// MARK: - Public Configuration
extension UIPostDataView {
    public func configure(with user: Users) {
    
    }
}
