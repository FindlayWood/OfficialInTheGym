//
//  CreateNewPostViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 26/08/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit

class CreateNewPostViewController: UIViewController {
    
    weak var coordinator: CreateNewPostCoordinator?

    var display = CreateNewPostView()
    
    var assignee: Assignable!
    
    var viewModel: CreateNewPostViewModel = {
        return CreateNewPostViewModel()
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .lightColour
        initDisplay()
        initViewModel()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        display.frame = getFullViewableFrame()
        view.addSubview(display)
    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    func initDisplay() {
        display.cancelButton.addTarget(self, action: #selector(cancelTapped(_:)), for: .touchUpInside)
        display.postButton.addTarget(self, action: #selector(postTapped(_:)), for: .touchUpInside)
        display.photoButton.addTarget(self, action: #selector(attachmentTapped(_:)), for: .touchUpInside)
        display.clipButton.addTarget(self, action: #selector(clipTapped(_:)), for: .touchUpInside)
        display.postButton.addTarget(self, action: #selector(postTapped(_:)), for: .touchUpInside)
        display.workoutButton.addTarget(self, action: #selector(workoutTapped(_:)), for: .touchUpInside)
        display.messageText.delegate = self
    }
    func initViewModel() {
        viewModel.succesfullyPostedClosure = { [weak self] in
            guard let self = self else {return}
            self.showTopAlert(with: "Successfully posted!")
            self.display.removeAttachment()
        }
        viewModel.errorPostingClosure = { [weak self] in
            guard let self = self else {return}
            self.showTopAlert(with: "Error posting. Try again.")
        }
        viewModel.assignee = assignee
    }
}

extension CreateNewPostViewController {
    @objc func cancelTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    @objc func postTapped(_ sender: UIButton) {
        viewModel.postTapped()
    }
    @objc func attachmentTapped(_ sender: UIButton) {
        coordinator?.showImagePicker(completion: { [display] pickedImage in
            display.addImage(pickedImage)
        })
    }
    @objc func clipTapped(_ sender: UIButton) {
        coordinator?.showClipPicker()
    }
    @objc func workoutTapped(_ sender: UIButton) {
        coordinator?.showSavedWorkoutPicker(completion: { [display, viewModel] pickedSavedWorkout in
            display.addWorkout(pickedSavedWorkout)
            viewModel.updateAttachedWorkout(with: pickedSavedWorkout)
        })
    }
}


extension CreateNewPostViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.white
        }
    }
    func textViewDidChange(_ textView: UITextView) {
        if textView.text.trimTrailingWhiteSpaces() == "" {
            display.postButton.isEnabled = false
        } else {
            display.postButton.isEnabled = true
        }
    }
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        viewModel.updateText(with: newText)
        let numberOfChars = newText.count
        return numberOfChars < 500
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty || textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            textView.text = display.placeholder
            textView.textColor = UIColor.lightGray
            display.postButton.isEnabled = false
        }
    }
}
