//
//  TextViewTableViewCell.swift
//  InTheGym
//
//  Created by Findlay Wood on 16/08/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit

/// tableview cell that constains only a textview
class TextViewTableViewCell: UITableViewCell {
    
    // MARK: - Callback
    /// when the textview text changes a callback is needed to update the size of the row
    var textChanged: ((String) -> Void)?
    
    // MARK: - Properties
    /// static cellID
    static let cellID = "TextViewTableViewCellID"
    
    // MARK: - Subviews
    lazy var textView: UITextView = {
        let view = UITextView()
        view.backgroundColor = .offWhiteColour
        view.layer.cornerRadius = 8
        view.tintColor = .darkColour
        view.font = .systemFont(ofSize: 16)
        view.textColor = .darkGray
        view.isScrollEnabled = false
        view.delegate = self
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: - Initializer
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        //textView.delegate = self
    }
    
    func textChanged(action: @escaping (String) -> Void) {
        self.textChanged = action
    }
}

// MARK: - UI Setup
private extension TextViewTableViewCell {
    func setupUI() {
        backgroundColor = .white
        selectionStyle = .none
        isUserInteractionEnabled = true
        contentView.addSubview(textView)
        constrainUI()
    }
    func constrainUI() {
        NSLayoutConstraint.activate([textView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 5),
                                     textView.topAnchor.constraint(equalTo: topAnchor, constant: 5),
                                     textView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -5),
                                     textView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5)])
    }
}

// MARK: - Configure
extension TextViewTableViewCell {
    public func configureCell(with text: String) {
        textView.text = text
    }
}

// MARK: - Textview delegate
extension TextViewTableViewCell: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        textChanged?(textView.text)
    }
}
