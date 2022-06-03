//
//  AddNewTagView.swift
//  InTheGym
//
//  Created by Findlay Wood on 26/05/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit

class AddNewTagView: UIView {
    
    // MARK: - Properties
    
    // MARK: - Subviews
    var cancelButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "xmark", withConfiguration: UIImage.SymbolConfiguration(scale: .large)), for: .normal)
        button.tintColor = .darkColour
        button.imageView?.contentMode = .scaleAspectFill
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    var imageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.backgroundColor = .clear
        view.heightAnchor.constraint(equalToConstant: 100).isActive = true
        view.widthAnchor.constraint(equalToConstant: 100).isActive = true
        view.image = UIImage(named: "tag_icon")
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var label: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.textAlignment = .center
        label.text = "Add a new tag for this exercise. Tags help people search for exercises and could include the body part the exercise targets, the kind of exercise it is, how often to perform the exercise etc."
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var textfield: UITextField = {
        let view = UITextField()
        view.backgroundColor = .secondarySystemBackground
        view.layer.cornerRadius = 8
        view.placeholder = "add tag..."
        view.font = .systemFont(ofSize: 20, weight: .semibold)
        view.returnKeyType = .done
        view.tintColor = .darkColour
        view.heightAnchor.constraint(equalToConstant: 48).isActive = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var exampleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.textColor = .label
        label.text = "#"
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var addButton: UIButton = {
        let button = UIButton()
        button.setTitle("Add", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .medium)
        button.backgroundColor = .darkColour
        button.heightAnchor.constraint(equalToConstant: 48).isActive = true
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    lazy var stack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [imageView,label,textfield,exampleLabel,addButton])
        stack.axis = .vertical
        stack.spacing = 16
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
private extension AddNewTagView {
    func setupUI() {
        backgroundColor = .secondarySystemBackground
        addSubview(cancelButton)
        addSubview(stack)
        configureUI()
    }
    
    func configureUI() {
        NSLayoutConstraint.activate([
            cancelButton.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            cancelButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            stack.topAnchor.constraint(equalTo: topAnchor, constant: 32),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor),
            label.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.7),
            textfield.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.8),
            addButton.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.8),
        ])
    }
}
// MARK: - Public COnfig
extension AddNewTagView {
    public func setAddButton(to enabled: Bool) {
        addButton.backgroundColor = enabled ? .darkColour : .darkColour.withAlphaComponent(0.6)
        addButton.isUserInteractionEnabled = enabled ? true : false
        addButton.setTitleColor(enabled ? .white : .secondaryLabel, for: .normal)
    }
    public func setExampleLabel(to text: String) {
        exampleLabel.text = "#" + text.lowercased().filter { !$0.isWhitespace }
    }
}
