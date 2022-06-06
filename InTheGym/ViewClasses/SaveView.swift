//
//  SaveView.swift
//  InTheGym
//
//  Created by Findlay Wood on 12/01/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit

class UISaveView: UIView {
    
    // MARK: - Properties
    var saving: Bool = true
    
    // MARK: - Subviews
    var topLabel: UILabel = {
        let label = UILabel()
        label.text = "Save"
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textAlignment = .center
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var savingButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "Workout Completed"), for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    lazy var stack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [topLabel, savingButton])
        stack.axis = .vertical
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
private extension UISaveView {
    func setupUI() {
        backgroundColor = .secondarySystemBackground
        layer.cornerRadius = 8
        layer.borderColor = UIColor.darkColour.cgColor
//        layer.borderWidth = 2
        addSubview(stack)
        configureUI()
    }
    func configureUI() {
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
    @objc func buttonTapped(_ sender: UIButton) {
        self.saving.toggle()
        let newButtonImage = saving ? UIImage(named: "Workout Completed") : UIImage(named: "Workout UnCompleted")
        savingButton.setImage(newButtonImage, for: .normal)
    }
}
// MARK: - Public Configuration
extension UISaveView {
    public func configure(with saving: Bool) {
        let newButtonImage = saving ? UIImage(named: "Workout Completed") : UIImage(named: "Workout UnCompleted")
        savingButton.setImage(newButtonImage, for: .normal)
    }
}
