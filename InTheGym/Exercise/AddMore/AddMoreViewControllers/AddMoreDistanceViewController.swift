//
//  AddMoreDistanceViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 21/08/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit

class AddMoreDistanceViewController: UIViewController {

    var display = AddMoreBasicView()
    
    let message = "Add a distance to complete each set for this exercise. Adding a distance will not be appropriate for every exercise."

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
        navigationItem.title = "Add Distance"
    }
    func initBarButton() {
        let barButton = UIBarButtonItem(title: "Add", style: .done, target: self, action: #selector(addPressed))
        navigationItem.rightBarButtonItem = barButton
    }
    func initDisplay() {
        display.setButtonTitlesTo("Metres", "km", "miles", message)
        display.buttoneOne.addTarget(self, action: #selector(metresPressed), for: .touchUpInside)
        display.buttoneTwo.addTarget(self, action: #selector(kmPressed), for: .touchUpInside)
        display.buttoneThree.addTarget(self, action: #selector(milesPressed), for: .touchUpInside)
    }

}

extension AddMoreDistanceViewController {
    @objc func addPressed() {
        
    }
    @objc func metresPressed() {
        display.weightMeasurementField.text = "m"
        display.numberTextfield.becomeFirstResponder()
    }
    @objc func kmPressed() {
        display.weightMeasurementField.text = "km"
        display.numberTextfield.becomeFirstResponder()
    }
    @objc func milesPressed() {
        display.weightMeasurementField.text = "miles"
        display.numberTextfield.becomeFirstResponder()
    }
}
