//
//  DisplayNoteView.swift
//  InTheGym
//
//  Created by Findlay Wood on 20/08/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit

class DisplayNoteView: UIView {
    // MARK: - Subviews
    var noteLabel: UILabel = {
        let label = UILabel()
        label.text = "NOTE"
        label.font = Constants.font
        label.textColor = .darkColour
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var note: UITextView = {
        let view = UITextView()
        view.font = .systemFont(ofSize: 18, weight: .medium)
        view.textColor = .darkGray
        view.tintColor = .darkColour
        view.addToolBar()
        view.layer.borderWidth = 2.0
        view.layer.borderColor = UIColor.black.cgColor
        view.layer.cornerRadius = 5
        view.backgroundColor = .white
        view.isScrollEnabled = false
        view.isUserInteractionEnabled = false
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var saveButton: UIButton = {
        let button = UIButton()
        button.setTitle("Save", for: .normal)
        button.setTitleColor(.darkColour, for: .normal)
        button.setTitleColor(.lightGray, for: .disabled)
        button.isEnabled = false
        button.titleLabel?.font = .boldSystemFont(ofSize: 18)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    var cancelButton: UIButton = {
        let button = UIButton()
        button.setTitle("cancel", for: .normal)
        button.setTitleColor(.darkColour, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
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

private extension DisplayNoteView {
    func setupUI() {
        backgroundColor = .offWhiteColour
        addSubview(cancelButton)
        addSubview(noteLabel)
        addSubview(saveButton)
        addSubview(note)
        constrainUI()
    }
    func constrainUI() {
        NSLayoutConstraint.activate([cancelButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 5),
                                     cancelButton.topAnchor.constraint(equalTo: topAnchor, constant: 5),
                                     
                                     noteLabel.topAnchor.constraint(equalTo: topAnchor, constant: 5),
                                     noteLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
        
                                     saveButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -5),
                                     saveButton.topAnchor.constraint(equalTo: topAnchor, constant: 5),
        
                                     note.topAnchor.constraint(equalTo: topAnchor, constant: 50),
                                     note.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
                                     note.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
                                     note.bottomAnchor.constraint(equalTo: bottomAnchor)])
    }
}

extension DisplayNoteView {
    public func configureView(with currentNote: String?) {
        note.text = currentNote
    }
}

