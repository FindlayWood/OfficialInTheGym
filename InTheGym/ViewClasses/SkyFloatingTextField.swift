//
//  SkyFloatingTextField.swift
//  InTheGym
//
//  Created by Findlay Wood on 03/12/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField


class SkyFloatingTextField: UIView {
    // MARK: - Properties
    
    // MARK: - Subviews
    var textfield: SkyFloatingLabelTextField = {
        let field = SkyFloatingLabelTextField()
        field.font = .systemFont(ofSize: 20, weight: .medium)
        field.tintColor = .darkColour
        field.returnKeyType = .done
        field.textColor = .darkColour
        field.placeholderColor = .lightGray
        field.selectedLineHeight = 4
        field.lineHeight = 1
        field.titleColor = .black
        field.lineColor = .lightGray
        field.selectedTitleColor = .darkColour
        field.selectedLineColor = .darkColour
        field.clearButtonMode = .whileEditing
        field.autocapitalizationType = .none
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
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
private extension SkyFloatingTextField {
    func setupUI() {
        addSubview(textfield)
        configureUI()
    }
    
    func configureUI() {
        NSLayoutConstraint.activate([
            textfield.topAnchor.constraint(equalTo: topAnchor),
            textfield.leadingAnchor.constraint(equalTo: leadingAnchor),
            textfield.trailingAnchor.constraint(equalTo: trailingAnchor),
            textfield.bottomAnchor.constraint(equalTo: bottomAnchor),
            textfield.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
}

extension SkyFloatingTextField {
    public func configure(with text: String) {
        textfield.placeholder = text
        textfield.title = text
        textfield.selectedTitle = text
    }
}

