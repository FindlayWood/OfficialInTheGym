//
//  UITextView+Extension.swift
//  InTheGym
//
//  Created by Findlay Wood on 21/08/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit
import Combine

extension UITextView {
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
    var textChangedPublisher: AnyPublisher<String,Never> {
        NotificationCenter.default.publisher(for: UITextView.textDidChangeNotification, object: self)
            .compactMap { ($0.object as? UITextView)?.text }
            .eraseToAnyPublisher()
    }
    var textBeganPublisher: AnyPublisher<String,Never> {
        NotificationCenter.default.publisher(for: UITextView.textDidBeginEditingNotification, object: self)
            .compactMap { ($0.object as? UITextView)?.text }
            .eraseToAnyPublisher()
    }
    var textEndedPublsiher: AnyPublisher<String,Never> {
        NotificationCenter.default.publisher(for: UITextView.textDidEndEditingNotification, object: self)
            .compactMap { ($0.object as? UITextView)?.text }
            .eraseToAnyPublisher()
    }
}
