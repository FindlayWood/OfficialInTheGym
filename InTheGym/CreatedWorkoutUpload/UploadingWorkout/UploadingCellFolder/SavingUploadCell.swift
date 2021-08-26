//
//  SavingUploadCell.swift
//  InTheGym
//
//  Created by Findlay Wood on 23/08/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit

class SavingUploadCell: BaseUploadCell {
    
    // MARK: - Properties
    static let reuseIdentifier = "SavingUploadCellID"
    
    weak var delegate: UploadingCellActions?
    
    // MARK: - Subviews
    var switchControl: UISwitch = {
        let view = UISwitch()
        view.isOn = true
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
private extension SavingUploadCell {
    func setupUI() {
        addSubview(switchControl)
        switchControl.addTarget(self, action: #selector(switchChangedValue(_:)), for: .valueChanged)
        constrainUI()
    }
    func constrainUI() {
        NSLayoutConstraint.activate([
            switchControl.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            switchControl.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10)
        ])
    }
}

// MARK: - Configure
extension SavingUploadCell: UploadCellConfigurable {
    func setup(with model: UploadCellModelProtocol) {
        label.text = model.title
        textView.text = model.message
    }
    
}

extension SavingUploadCell {
    @objc func switchChangedValue(_ sender: UISwitch) {
        delegate?.savingSwitchChanged()
        switch sender.isOn {
        case true:
            setToSaving()
        case false:
            setToNotSaving()
        }
    }
    
    func setToSaving() {
        UIView.animate(withDuration: 0.3) {
            self.label.textColor = .darkColour
            self.circleViewOne.backgroundColor = .lightColour
            self.circleViewTwo.backgroundColor = .lightColour
        }
    }
    func setToNotSaving() {
        UIView.animate(withDuration: 0.3) {
            self.label.textColor = .darkGray
            self.circleViewOne.backgroundColor = .lightGray
            self.circleViewTwo.backgroundColor = .lightGray
        }
    }
}
