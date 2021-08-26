//
//  BaseUploadCell.swift
//  InTheGym
//
//  Created by Findlay Wood on 23/08/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit

class BaseUploadCell: UICollectionViewCell {
    
    // MARK: - Properties
    private let viewDimension: CGFloat = 100
    
    // MARK: - Subviews
    var label: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 25, weight: .bold)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        label.textColor = .darkColour
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var textView: UITextView = {
        let view = UITextView()
        view.addToolBar()
        view.font = .systemFont(ofSize: 14, weight: .medium)
        view.textColor = .darkGray
        view.backgroundColor = .clear
        view.isScrollEnabled = true
        view.isUserInteractionEnabled = false
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    lazy var circleViewOne: UIView = {
        let view = UIView()
        view.backgroundColor = .lightColour
        view.alpha = 0.6
        view.layer.cornerRadius = 50
        view.widthAnchor.constraint(equalToConstant: viewDimension).isActive = true
        view.heightAnchor.constraint(equalToConstant: viewDimension).isActive = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    lazy var circleViewTwo: UIView = {
        let view = UIView()
        view.backgroundColor = .lightColour
        view.alpha = 0.6
        view.layer.cornerRadius = 50
        view.widthAnchor.constraint(equalToConstant: viewDimension).isActive = true
        view.heightAnchor.constraint(equalToConstant: viewDimension).isActive = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
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
private extension BaseUploadCell {
    func setupUI() {
        backgroundColor = .offWhiteColour
        layer.cornerRadius = 10
        clipsToBounds = true
        addSubview(circleViewOne)
        addSubview(circleViewTwo)
        addSubview(label)
        addSubview(textView)
        constrainUI()
    }
    func constrainUI() {
        NSLayoutConstraint.activate([
            circleViewOne.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 40),
            circleViewOne.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 20),
            circleViewTwo.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 10),
            circleViewTwo.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 50),
            
            label.topAnchor.constraint(equalTo: topAnchor, constant: 5),
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 5),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -5),
            
            textView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 5),
            textView.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 5),
            textView.trailingAnchor.constraint(equalTo: circleViewTwo.leadingAnchor),
            textView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5)
        ])
    }
}
extension BaseUploadCell: CellReSizable {
    func cellSize(text: String) -> CGSize {
        let width = textView.frame.width
        let label: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.text = text
        label.sizeToFit()
        return CGSize(width: width, height: label.frame.height + 40)
    }
}
