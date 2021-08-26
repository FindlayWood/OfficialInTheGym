//
//  AddMoreRestTimeViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 21/08/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit

class AddMoreRestTimeViewController: UIViewController {

    var display = AddMoreBasicView()
    
    let message = "Add a rest time for between each set for this exercise. Adding a rest time will not be appropriate for every exercise."

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        initDisplay()
        initBarButton()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        display.frame = getFullViewableFrame()
        view.addSubview(display)
    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        let textAttributes = [NSAttributedString.Key.foregroundColor: UIColor.darkColour]
        self.navigationController?.navigationBar.titleTextAttributes = textAttributes
        self.navigationController?.navigationBar.tintColor = UIColor.darkColour
        navigationItem.title = "Add Rest Time"
    }
    func initBarButton() {
        let barButton = UIBarButtonItem(title: "Add", style: .done, target: self, action: #selector(addPressed))
        navigationItem.rightBarButtonItem = barButton
    }
    func initDisplay() {
        display.numberTextfield.keyboardType = .numberPad
        display.setButtonTitlesTo("Seconds", "Minutes", nil, message)
        display.buttoneOne.addTarget(self, action: #selector(secondsPressed), for: .touchUpInside)
        display.buttoneTwo.addTarget(self, action: #selector(minutesPressed), for: .touchUpInside)
    }
}

extension AddMoreRestTimeViewController {
    @objc func addPressed() {
        
    }
    @objc func secondsPressed() {
        display.weightMeasurementField.text = "secs"
        display.numberTextfield.becomeFirstResponder()
    }
    @objc func minutesPressed() {
        display.weightMeasurementField.text = "mins"
        display.numberTextfield.becomeFirstResponder()
    }
}
