//
//  CustomSegmentControl.swift
//  InTheGym
//
//  Created by Findlay Wood on 16/02/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit
import Combine

class CustomSegmentControl: UIView {
    
    // MARK: - Publishers
    var selectedIndex = PassthroughSubject<Int,Never>()
    
    // MARK: - Properties
    private var buttons = [UIButton]()
    
    var selectedTextColour: UIColor = .white
    var selectedViewColour: UIColor = .darkColour
    var textColour: UIColor = .black
    
    // MARK: - Subviews
    var selectorView: UIView = {
        let view = UIView()
        view.backgroundColor = .darkColour
        view.translatesAutoresizingMaskIntoConstraints = true
        return view
    }()
    
    var descriptionButton: UIButton = {
        let button = UIButton()
        button.setTitle("Descriptions", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 20)
        button.addTarget(self, action: #selector(buttonAction(_:)), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    var clipButton: UIButton = {
        let button = UIButton()
        button.setTitle("Clips", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.addTarget(self, action: #selector(buttonAction(_:)), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    lazy var stackview: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [descriptionButton, clipButton])
        stack.axis = .horizontal
        stack.alignment = .fill
        stack.distribution = .fillEqually
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
    
    override func layoutSubviews() {
        super.layoutSubviews()
        selectorView.frame = CGRect(x: 0, y: 0, width: frame.width / 2, height: frame.height)
        selectorView.layer.cornerRadius = frame.height / 2
        layer.cornerRadius = frame.height / 2
    }
    
}
// MARK: - Configure
private extension CustomSegmentControl {
    func setupUI() {
        addSubview(selectorView)
        addSubview(stackview)
        buttons.append(descriptionButton)
        buttons.append(clipButton)
        layer.borderWidth = 2
        layer.borderColor = UIColor.darkColour.cgColor
        configureUI()
    }
    
    func configureUI() {
        NSLayoutConstraint.activate([
            stackview.topAnchor.constraint(equalTo: topAnchor),
            stackview.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackview.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackview.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    @objc func buttonAction(_ sender: UIButton) {
        for (index, button) in buttons.enumerated() {
            button.setTitleColor(textColour, for: .normal)
            button.titleLabel?.font = .systemFont(ofSize: 18, weight: .medium)
            if button == sender {
                selectedIndex.send(index)
                let position = frame.width / CGFloat(buttons.count) * CGFloat(index)
                UIView.animate(withDuration: 0.3) {
                    self.selectorView.frame.origin.x = position
                    button.setTitleColor(self.selectedTextColour, for: .normal)
                    button.titleLabel?.font = .boldSystemFont(ofSize: 20)
                }
            }
        }
    }
    func configureSelectorView() {
        let selectorWidth: CGFloat = frame.width / CGFloat(buttons.count)
        selectorView = UIView(frame: CGRect(x: 0, y: 0, width: selectorWidth, height: frame.height))
        selectorView.backgroundColor = selectedViewColour
        addSubview(selectorView)
    }
    
    func configureStack() {
        for button in buttons {
            stackview.addArrangedSubview(button)
        }
    }
}
// MARK: - Public Configuration
extension CustomSegmentControl {
    public func configure() {
//        subviews.forEach( {$0.removeFromSuperview()} )
//        for title in titles {
//            let button = UIButton(type: .system)
//            button.setTitleColor(textColour, for: .normal)
//            button.setTitle(title, for: .normal)
//            button.addTarget(self, action: #selector(buttonAction(_:)), for: .touchUpInside)
//            buttons.append(button)
//        }
//        buttons[0].setTitleColor(selectedTextColour, for: .normal)
        descriptionButton.setTitleColor(.white, for: .normal)
//        configureSelectorView()
//        configureStack()
    }
}

class PPPPPP: UIView {
    // MARK: - Properties
    var buttonTitles = [String]()
    var buttons = [UIButton]()
    var selectedView: UIView!
    
    var textColour: UIColor = .black
    var selectedTextColour: UIColor = .white
    var selectedViewColour: UIColor = .darkColour
    
     // MARK: - Subviews
    

    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        layer.cornerRadius = frame.height / 2
    }
        
    func updateView() {
        subviews.forEach( {$0.removeFromSuperview()} )
        for buttonTitle in buttonTitles {
            let button = UIButton(type: .system)
            button.setTitle(buttonTitle, for: .normal)
            button.setTitleColor(textColour, for: .normal)
            buttons.append(button)
        }
        
        let stack = UIStackView(arrangedSubviews: buttons)
        stack.alignment = .fill
        stack.distribution = .fillEqually
        stack.axis = .horizontal
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)
        stack.topAnchor.constraint(equalTo: topAnchor).isActive = true
        stack.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        stack.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        stack.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }

}
