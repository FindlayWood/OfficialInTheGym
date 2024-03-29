//
//  AddMoreNoteViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 04/09/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit

class AddMoreNoteViewController: UIViewController {

    weak var coordinator: AddMoreToExerciseCoordinator?
    
    weak var newExercise: exercise?
    
    var display = DisplayNoteView()
    
    var exerciseViewModel: ExerciseCreationViewModel!
    
    var currentNote: String?
    
    var cellModel: AddMoreCellModel!
    
    var viewModel = AddMoreViewModel()
    
    override func loadView() {
        view = display
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        initDisplay()
    }
    
    func initDisplay() {
        display.note.text = viewModel.exercise.note
        display.note.delegate = self
        display.note.isUserInteractionEnabled = true
        display.saveButton.addTarget(self, action: #selector(saveTapped(_:)), for: .touchUpInside)
        display.cancelButton.addTarget(self, action: #selector(cancelTapped(_:)), for: .touchUpInside)
    }
    
    @objc func saveTapped(_ sender: UIButton) {
        guard let noteText = display.note.text else {return}
        cellModel.value.value = "Added"
        viewModel.noteAdded(noteText)
        dismiss(animated: true)
    }
    @objc func cancelTapped(_ sender: UIButton) {
        self.dismiss(animated: true)
    }

}

extension AddMoreNoteViewController: UITextViewDelegate {
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
