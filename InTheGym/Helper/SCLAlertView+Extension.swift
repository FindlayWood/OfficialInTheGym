//
//  SCLAlertView+Extension.swift
//  InTheGym
//
//  Created by Findlay Wood on 20/01/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit
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
    
    func showError(title: String = "Error!", subtitle: String = "There was an error. Please try again.") {
        let alert = SCLAlertView()
        alert.showError(title, subTitle: subtitle, closeButtonTitle: "Ok")
    }
    func showSuccess(title: String = "Success!", subtitle: String = "Success.") {
        let alert = SCLAlertView()
        alert.showSuccess(title, subTitle: subtitle)
    }
    
    func showButtonAlert(title: String, subtitle: String, buttonAction: @escaping () -> Void) {
        let alert = SCLAlertView()
        alert.addButton("Yes", action: buttonAction)
        alert.showWarning(title, subTitle: subtitle, closeButtonTitle: "No", colorStyle: .red, colorTextButton: .white)
    }
}
