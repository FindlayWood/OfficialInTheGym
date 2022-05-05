//
//  UITextfield+Extension.swift
//  InTheGym
//
//  Created by Findlay Wood on 21/08/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit
import Combine

extension UITextField {
    func addToolBar() {
        let bar = UIToolbar()
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(dismissKeyboard))
        bar.items = [flexibleSpace, done]
        bar.sizeToFit()
        self.inputAccessoryView = bar
    }
    @objc func dismissKeyboard() {
        self.resignFirstResponder()
    }
    
    var textPublisher: AnyPublisher<String,Never> {
        NotificationCenter.default.publisher(for: UITextField.textDidChangeNotification, object: self)
            .compactMap { ($0.object as? UITextField)?.text }
            .eraseToAnyPublisher()
    }
}
