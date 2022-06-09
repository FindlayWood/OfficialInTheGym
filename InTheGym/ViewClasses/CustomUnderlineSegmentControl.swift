//
//  CustomUnderlineSegmentControl.swift
//  InTheGym
//
//  Created by Findlay Wood on 20/03/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit
import Combine

class CustomUnderlineSegmentControl: UIView {
    
    // MARK: - Publisher
    var selectedIndex = PassthroughSubject<Int,Never>()
    
    // MARK: - Properties
    private  var buttonTitles: [String]!
    private var buttons: [UIButton]!
    private var selectedView: UIView!
    
    var textColour: UIColor = .darkGray
    var selectedTextColour: UIColor = .darkColour
    var selectedViewColour: UIColor = .darkColour
    
     // MARK: - Subviews
    
    // MARK: - Configuration
    private func configureStackView() {
        let stack = UIStackView(arrangedSubviews: buttons)
        stack.axis = .horizontal
        stack.alignment = .fill
        stack.distribution = .fillEqually
        addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        addFullConstraint(to: stack)
    }
    
    private func configureSelectorView() {
        let selectorWidth = frame.width / CGFloat(self.buttonTitles.count)
        selectedView = UIView(frame: CGRect(x: 0, y: frame.height - 2, width: selectorWidth, height: 2))
        selectedView.backgroundColor = selectedViewColour
//        selectedView.layer.cornerRadius = frame.height / 2
        addSubview(selectedView)
    }
    
    // MARK: - Button Creation
    private func createButton() {
        buttons = [UIButton]()
        buttons.removeAll()
        subviews.forEach { $0.removeFromSuperview() }
        for buttonTitle in buttonTitles {
            let button = UIButton(type: .system)
            button.setTitle(buttonTitle, for: .normal)
            button.addTarget(self, action: #selector(buttonAction(_:)), for: .touchUpInside)
            button.setTitleColor(textColour, for: .normal)
            button.titleLabel?.font = .systemFont(ofSize: 18, weight: .medium)
            button.titleLabel?.adjustsFontSizeToFitWidth = true
            button.titleLabel?.minimumScaleFactor = 0.2
            buttons.append(button)
        }
        buttons[0].setTitleColor(selectedTextColour, for: .normal)
        buttons[0].titleLabel?.font = .boldSystemFont(ofSize: 20)
    }
    
    // MARK: - Target
    @objc func buttonAction(_ sender: UIButton) {
        for (index, button) in buttons.enumerated() {
            button.setTitleColor(textColour, for: .normal)
            button.titleLabel?.font = .systemFont(ofSize: 18, weight: .medium)
            if button == sender {
                selectedIndex.send(index)
                button.titleLabel?.font = .boldSystemFont(ofSize: 20)
                let selectorPosition = frame.width / CGFloat(buttonTitles.count) * CGFloat(index)
                UIView.animate(withDuration: 0.3) {
                    self.selectedView.frame.origin.x = selectorPosition
                }
                button.setTitleColor(selectedTextColour, for: .normal)
            }
        }
    }
    
    // MARK: - Update View
    private func updateView() {
        createButton()
        configureSelectorView()
        configureStackView()
    }
    
    // MARK: - Initializer
    convenience init(frame: CGRect, buttonTitles: [String]) {
        self.init(frame: frame)
        self.buttonTitles = buttonTitles
        self.updateView()
    }
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        super.draw(rect)
//        layer.cornerRadius = frame.height / 2
//        layer.borderWidth = 2
//        layer.borderColor = UIColor.darkColour.cgColor
//        updateView()
    }
    
    func setButtonTitles(buttonTitle: [String]) {
        self.buttonTitles = buttonTitle
        updateView()
    }
    
    public func setIndex(to index: Int) {
        self.buttonAction(buttons[index])
    }
}
