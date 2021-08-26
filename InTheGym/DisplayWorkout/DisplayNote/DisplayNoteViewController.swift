//
//  DisplayNoteViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 20/08/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit

class DisplayNoteViewController: UIViewController {
    
    var display = DisplayNoteView()
    
    var currentNote: String?
    var currentWorkout: WorkoutDelegate!
    var noteIndex: Int!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .offWhiteColour
        initDisplay()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        display.frame = getViewableFrameWithBottomSafeArea()
        view.addSubview(display)
    }
    func initDisplay() {
        display.cancelButton.addTarget(self, action: #selector(remove), for: .touchUpInside)
        display.saveButton.addTarget(self, action: #selector(saveTapped(_:)), for: .touchUpInside)
        display.configureView(with: currentNote)
        display.note.delegate = self
        if currentWorkout.creatorID == FirebaseAuthManager.currentlyLoggedInUser.uid {
            display.note.isUserInteractionEnabled = true
        }
    }

}

// MARK: - Actions
extension DisplayNoteViewController {
    @objc func remove() {
        self.dismiss(animated: true, completion: nil)
    }
    @objc func saveTapped(_ sender: UIButton) {
        
    }
}


extension DisplayNoteViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        if textView.text.trimTrailingWhiteSpaces() == "" || textView.text.trimTrailingWhiteSpaces() == currentNote {
            display.saveButton.isEnabled = false
        } else {
            display.saveButton.isEnabled = true
        }
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        textView.text = textView.text.trimTrailingWhiteSpaces()
    }
}
