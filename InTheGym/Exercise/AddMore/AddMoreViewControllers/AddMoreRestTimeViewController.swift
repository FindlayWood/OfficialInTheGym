//
//  AddMoreRestTimeViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 21/08/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit

class AddMoreRestTimeViewController: UIViewController {
    
    weak var coordinator: AddMoreToExerciseCoordinator?

    var display = AddMoreBasicView()
    
    var cellModel: AddMoreCellModel!
    
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
        navigationItem.rightBarButtonItem?.isEnabled = false
    }
    func initDisplay() {
        display.numberTextfield.keyboardType = .numberPad
        display.numberTextfield.delegate = self
        display.setButtonTitlesTo("Seconds", "Minutes", nil, message)
        display.buttoneOne.addTarget(self, action: #selector(secondsPressed), for: .touchUpInside)
        display.buttoneTwo.addTarget(self, action: #selector(minutesPressed), for: .touchUpInside)
    }
    func emptyCheck() -> Bool {
        return display.numberTextfield.text == "" || display.weightMeasurementField.text == ""
    }
}

extension AddMoreRestTimeViewController {
    @objc func addPressed() {
        guard let enteredTime = display.numberTextfield.text,
              let enteredWeight = display.weightMeasurementField.text
        else {return}
        guard var timeInt = Int(enteredTime) else {return}
        if display.weightMeasurementField.text == "mins" {
            timeInt = timeInt * 60
        }
        cellModel.value.value = enteredTime + enteredWeight
        coordinator?.restTimeAdded(timeInt)
    }
    @objc func secondsPressed() {
        display.weightMeasurementField.text = "secs"
        display.numberTextfield.becomeFirstResponder()
        navigationItem.rightBarButtonItem?.isEnabled = !emptyCheck()
    }
    @objc func minutesPressed() {
        display.weightMeasurementField.text = "mins"
        display.numberTextfield.becomeFirstResponder()
        navigationItem.rightBarButtonItem?.isEnabled = !emptyCheck()
    }
}

extension AddMoreRestTimeViewController {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let newString = (textField.text! as NSString).replacingCharacters(in: range, with: string).trimTrailingWhiteSpaces()
        navigationItem.rightBarButtonItem?.isEnabled = (newString != "") && (display.weightMeasurementField.text != "")
        return true
    }
}
