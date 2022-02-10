//
//  SCLAlertView+Extension.swift
//  InTheGym
//
//  Created by Findlay Wood on 20/01/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
import SCLAlertView

extension UIViewController {
    
    func showRPEAlert(for index: IndexPath, completion: @escaping (IndexPath, Int) -> ()) {
        let alert = SCLAlertView()
        let textfield = alert.addTextField()
        textfield.placeholder = "enter rpe from 1 to 10..."
        textfield.keyboardType = .numberPad
        textfield.becomeFirstResponder()
        alert.addButton("SAVE") {
            if let text = textfield.text {
                if let textInt = Int(text) {
                    if textInt > 0 && textInt < 11 {
                        completion(index, textInt)
                    } else {
                        self.showError(title: "Error", subtitle: "Enter RPE between 1 and 10.")
                    }
                }
            } else {
                self.showError(title: "Error", subtitle: "Enter RPE between 1 and 10.")
            }
        }
        alert.showSuccess("RPE", subTitle: "Enter RPE score for this exercise.", closeButtonTitle: "Cancel")
    }
    
    func showRPEEMOM(completion: @escaping (Int) -> Void) {
        let alert = SCLAlertView()
        let rpe = alert.addTextField()
        rpe.placeholder = "enter rpe 1-10..."
        rpe.keyboardType = .numberPad
        rpe.becomeFirstResponder()
        alert.addButton("Save") {
            guard let score = rpe.text else {
                self.showError(title: "Error", subtitle: "Enter RPE between 1 and 10.")
                return}
            guard let scoreInt = Int(score) else {
                self.showError(title: "Error", subtitle: "Enter RPE between 1 and 10.")
                return}
            if scoreInt > 0 && scoreInt < 11 {
                completion(scoreInt)
            } else {
                self.showError(title: "Error", subtitle: "Enter RPE between 1 and 10.")
            }
        }
        alert.showSuccess("RPE", subTitle: "Enter RPE for EMOM(1-10).",closeButtonTitle: "cancel")
    }
    func showRPEAMRAP(completion: @escaping (Int) -> Void) {
        let alert = SCLAlertView()
        let rpe = alert.addTextField()
        rpe.placeholder = "enter rpe 1-10..."
        rpe.keyboardType = .numberPad
        rpe.becomeFirstResponder()
        alert.addButton("Save") {
            guard let score = rpe.text else {
                self.showError(title: "Error", subtitle: "Enter RPE between 1 and 10.")
                return}
            guard let scoreInt = Int(score) else {
                self.showError(title: "Error", subtitle: "Enter RPE between 1 and 10.")
                return}
            if scoreInt > 0 && scoreInt < 11 {
                completion(scoreInt)
            } else {
                self.showError(title: "Error", subtitle: "Enter RPE between 1 and 10.")
            }
        }
        alert.showSuccess("RPE", subTitle: "Enter RPE for AMRAP(1-10).",closeButtonTitle: "cancel")
    }

    func showWorkoutRPEAlert(completion: @escaping (Int) -> ()) {
        let alert = SCLAlertView()
        let textfield = alert.addTextField()
        textfield.placeholder = "enter rpe from 1 to 10..."
        textfield.keyboardType = .numberPad
        textfield.becomeFirstResponder()
        alert.addButton("SAVE") {
            if let text = textfield.text {
                if let textInt = Int(text) {
                    if textInt > 0 && textInt < 11 {
                        completion(textInt)
                    } else {
                        self.showError(title: "Error", subtitle: "Enter RPE between 1 and 10.")
                    }
                }
            } else {
                self.showError(title: "Error", subtitle: "Enter RPE between 1 and 10.")
            }
        }
        alert.showSuccess("RPE", subTitle: "Enter RPE score for this workout.", closeButtonTitle: "Cancel")
    }
    
    func showError(title: String, subtitle: String) {
        let alert = SCLAlertView()
        alert.showError(title, subTitle: subtitle, closeButtonTitle: "Ok")
    }
}
