//
//  UICurrentProgramView.swift
//  InTheGym
//
//  Created by Findlay Wood on 20/04/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit

class UICurrentProgramView: UIView {
    
    // MARK: - Properties
    
    // MARK: - Subviews
    var currentLabel: UILabel = {
        let label = UILabel()
        label.text = "Current Program"
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.textColor = .thirdColour
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 30, weight: .bold)
        label.textColor = .white
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var plusButton: UIButton = {
        let button = UIButton()
        let configuration = UIImage.SymbolConfiguration(pointSize: 30, weight: .semibold)
        button.setImage(UIImage(systemName: "plus", withConfiguration: configuration), for: .normal)
        button.tintColor = .darkGray
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    var plusLabel: UILabel = {
        let label = UILabel()
        label.text = "No Current Program. To add a current program selected one of your saved programs and then select make current program and then it will appear here."
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 17, weight: .medium)
        label.textColor = .darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var hstack: CurrentProgramHStack = {
        let view = CurrentProgramHStack()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var progressView: UIProgressView = {
        let view = UIProgressView()
        view.configure(percent: 0.4)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var stack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [currentLabel,titleLabel,plusButton,plusLabel,hstack,progressView])
        stack.axis = .vertical
        stack.spacing = 8
        stack.alignment = .center
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
private extension UICurrentProgramView {
    func setupUI() {
        layer.cornerRadius = 8
        layer.borderWidth = 2
        layer.borderColor = UIColor.darkColour.cgColor
        addViewShadow(with: .darkColour)
        backgroundColor = .thirdColour
        currentLabel.isHidden = true
        titleLabel.isHidden = true
        progressView.isHidden = true
        hstack.isHidden = true
        stack.setCustomSpacing(32, after: titleLabel)
        addSubview(stack)
        configureUI()
    }
    
    func configureUI() {
        addFullConstraint(to: stack, withConstant: 8)
        NSLayoutConstraint.activate([
            progressView.widthAnchor.constraint(equalTo: stack.widthAnchor)
        ])
    }
}

// MARK: - Public Configuration
extension UICurrentProgramView {
    public func addCurrentProgram() {
        titleLabel.text = "Jumping Start Program"
        currentLabel.isHidden = false
        titleLabel.isHidden = false
        backgroundColor = .darkColour
    }
    public func configure(with model: CurrentProgramModel) {
        plusButton.isHidden = true
        plusLabel.isHidden = true
        titleLabel.text = model.title
        currentLabel.isHidden = false
        titleLabel.isHidden = false
        hstack.isHidden = false
        progressView.isHidden = false
        backgroundColor = .darkColour
    }
}

// MARK: - Current Program H Stack
class CurrentProgramHStack: UIView {
    
    // MARK: - Properties
    
    // MARK: - Subviews
    var completedNumberLabel: UILabel = {
        let label = UILabel()
        label.text = "0"
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.textColor = .thirdColour
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var completedLabel: UILabel = {
        let label = UILabel()
        label.text = "Completed"
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    lazy var firstStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [completedNumberLabel,completedLabel])
        stack.axis = .vertical
        stack.spacing = 4
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    var totalNumberLabel: UILabel = {
        let label = UILabel()
        label.text = "16"
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.textColor = .thirdColour
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var totalLabel: UILabel = {
        let label = UILabel()
        label.text = "Total"
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    lazy var secondStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [totalNumberLabel,totalLabel])
        stack.axis = .vertical
        stack.spacing = 4
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    lazy var mainStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [firstStack,secondStack])
        stack.axis = .horizontal
        stack.spacing = 32
        stack.alignment = .center
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
private extension CurrentProgramHStack {
    func setupUI() {
        addSubview(mainStack)
        configureUI()
    }
    
    func configureUI() {
        addFullConstraint(to: mainStack)
    }
}
