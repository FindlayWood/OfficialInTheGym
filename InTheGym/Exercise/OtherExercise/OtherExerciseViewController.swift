//
//  OtherExerciseViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 20/08/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit

class OtherExerciseViewController: UIViewController {
    
    weak var coordinator: CreationDelegate?
    
    var newExercise: exercise?
    
    var display = OtherExerciseView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        initDisplay()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        display.frame = view.frame
        view.addSubview(display)
    }
    
    func initDisplay() {
        display.continueButton.addTarget(self, action: #selector(continueTapped(_:)), for: .touchUpInside)
        display.cancelButton.addTarget(self, action: #selector(cancelTapped(_:)), for: .touchUpInside)
    }
    
    @objc func continueTapped(_ sender: UIButton) {
        guard let newExercise = newExercise,
              let exerciseName = display.textfield.text
        else {return}
        newExercise.exercise = exerciseName
        newExercise.type = .CU
        dismiss(animated: true, completion: nil)
        coordinator?.exerciseSelected(newExercise)
    }
    @objc func cancelTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}
