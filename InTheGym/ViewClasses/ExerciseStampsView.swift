//
//  ExerciseStampsView.swift
//  InTheGym
//
//  Created by Findlay Wood on 15/06/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit

class ExerciseStampsView: UIView {
    // MARK: - Properties
    
    // MARK: - Subviews
    var verifiedImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.backgroundColor = .clear
        view.tintColor = .lightColour
        view.image = UIImage(systemName: "checkmark.seal.fill")
        view.heightAnchor.constraint(equalToConstant: 40).isActive = true
        view.widthAnchor.constraint(equalToConstant: 40).isActive = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var verifiedCountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = .label
        label.textAlignment = .center
        label.text = "0"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    lazy var verifiedStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [verifiedImageView, verifiedCountLabel])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 8
        return stack
    }()
    var eliteImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.backgroundColor = .clear
        view.tintColor = .goldColour
        view.image = UIImage(systemName: "checkmark.seal.fill")
        view.heightAnchor.constraint(equalToConstant: 40).isActive = true
        view.widthAnchor.constraint(equalToConstant: 40).isActive = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var eliteCountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = .label
        label.textAlignment = .center
        label.text = "0"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    lazy var eliteStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [eliteImageView, eliteCountLabel])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 8
        return stack
    }()
    lazy var mainStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [eliteStack, verifiedStack])
        stack.axis = .horizontal
        stack.alignment = .center
//        stack.distribution = .fillEqually
        stack.spacing = 32
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
private extension ExerciseStampsView {
    func setupUI() {
        addSubview(mainStack)
        configureUI()
    }
    func configureUI() {
        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: topAnchor),
            mainStack.leadingAnchor.constraint(equalTo: leadingAnchor),
            mainStack.trailingAnchor.constraint(equalTo: trailingAnchor),
            mainStack.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}
// MARK: - Public Config
extension ExerciseStampsView {
    public func eliteConfigure(_ count: Int) {
        if count > 0 {
            eliteStack.isHidden = false
            eliteCountLabel.text = count.description
        }
    }
    public func verifiedConfigure(_ count: Int) {
        if count > 0 {
            verifiedStack.isHidden = false
            verifiedCountLabel.text = count.description
        }
    }
}
