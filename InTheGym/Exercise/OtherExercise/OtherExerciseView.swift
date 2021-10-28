//
//  OtherExerciseView.swift
//  InTheGym
//
//  Created by Findlay Wood on 20/08/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField

class OtherExerciseView: UIView {
    
    // MARK: - Properties
    let messageText = "Make sure you have checked that the exercise you are looking for is not in the app. Using exercises already in the app makes it easier to record exercise data. If it does not exist enter the exercise name above, if you have previously entered the exercise - make sure to enter it exactly the same (they are case sensitive) to keep your stats accurate. We keep a track of all exercises entered manually to help us add more exercises to the app."
    
    // MARK: - Subview
    lazy var textfield: SkyFloatingLabelTextField = {
        let field = SkyFloatingLabelTextField()
        field.tintColor = Constants.darkColour
        field.returnKeyType = .done
        field.textColor = .black
        field.font = .systemFont(ofSize: 18, weight: .medium)
        field.placeholderColor = .lightGray
        field.selectedLineHeight = 4
        field.lineHeight = 2
        field.titleColor = .darkColour
        field.lineColor = .darkColour
        field.title = "Exercise Name"
        field.selectedTitle = "Exercise Name"
        field.selectedTitleColor = .darkColour
        field.selectedLineColor = .darkColour
        field.placeholder = "enter exercise name"
        field.clearButtonMode = .never
        field.delegate = self
        field.autocapitalizationType = .words
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    lazy var message: UITextView = {
        let view = UITextView()
        view.isScrollEnabled = false
        view.isUserInteractionEnabled = false
        view.text = messageText
        view.font = .systemFont(ofSize: 12, weight: .medium)
        view.textColor = .darkGray
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var continueButton: UIButton = {
        let button = UIButton()
        button.setTitle("Continue", for: .normal)
        button.setTitleColor(.darkColour, for: .normal)
        button.setTitleColor(.lightGray, for: .disabled)
        button.titleLabel?.font = .boldSystemFont(ofSize: 16)
        button.isEnabled = false
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    var cancelButton: UIButton = {
        let button = UIButton()
        button.setTitle("Cancel", for: .normal)
        button.setTitleColor(.darkColour, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 12)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
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

// MARK: - Setup UI
private extension OtherExerciseView {
    func setupUI() {
        backgroundColor = .white
        addSubview(textfield)
        addSubview(message)
        addSubview(continueButton)
        addSubview(cancelButton)
        constrainUI()
    }
    func constrainUI() {
        NSLayoutConstraint.activate([textfield.topAnchor.constraint(equalTo: topAnchor, constant: 40),
                                     textfield.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),
                                     textfield.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15),
                                     textfield.heightAnchor.constraint(equalToConstant: 45),
        
                                     message.topAnchor.constraint(equalTo: textfield.bottomAnchor, constant: 5),
                                     message.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),
                                     message.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15),
        
                                     continueButton.topAnchor.constraint(equalTo: topAnchor, constant: 5),
                                     continueButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -5),
                                     cancelButton.topAnchor.constraint(equalTo: topAnchor, constant: 5),
                                     cancelButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 5)])
    }
}

// MARK: - Textfield
extension OtherExerciseView: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let newString = (textField.text! as NSString).replacingCharacters(in: range, with: string).trimTrailingWhiteSpaces()
        continueButton.isEnabled = (newString != "")
        //continueButton.isEnabled = !newString.isEmpty
//        if newString == "" {
//            continueButton.isEnabled = false
//        } else {
//            continueButton.isEnabled = true
//        }
        return true
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
}
